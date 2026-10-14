package com.scanflow.app.scanflow

import android.content.ClipData
import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors
import java.io.File
import kotlin.math.abs
import kotlin.math.hypot
import kotlin.math.max
import org.opencv.android.OpenCVLoader
import org.opencv.core.Mat
import org.opencv.core.MatOfByte
import org.opencv.core.MatOfInt
import org.opencv.core.MatOfPoint
import org.opencv.core.MatOfPoint2f
import org.opencv.core.Point
import org.opencv.core.Size
import org.opencv.imgcodecs.Imgcodecs
import org.opencv.imgproc.Imgproc

class MainActivity : FlutterActivity() {
    private val edgeExecutor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())
    private data class PendingPdfSave(
        val source: File,
        val result: MethodChannel.Result,
        val successValue: Any? = true,
        val cancelValue: Any? = false,
    )
    private var pendingPdfSave: PendingPdfSave? = null

    companion object {
        private const val SAVE_PDF_REQUEST = 6248
        private const val SAVE_PDF_DOWNLOADS_REQUEST = 6249
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "scanflow/document_edges")
            .setMethodCallHandler { call, result ->
                if (call.method != "autoCorrect") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val bytes = call.arguments as? ByteArray
                if (bytes == null || bytes.isEmpty()) {
                    result.error("INVALID_IMAGE", "The image data is empty.", null)
                    return@setMethodCallHandler
                }
                edgeExecutor.execute {
                    try {
                        val corrected = correctDocumentEdges(bytes)
                        mainHandler.post { result.success(corrected) }
                    } catch (error: Throwable) {
                        mainHandler.post {
                            result.error("EDGE_PROCESSING", error.message ?: "Document edge correction failed.", null)
                        }
                    }
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "scanflow/pdf_files")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "savePdfToDevice" -> savePdfToDevice(call, result)
                    "savePdfToDownloads" -> savePdfToDownloads(call, result)
                    "sharePdf" -> sharePdf(call, result)
                    else -> result.notImplemented()
                }
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != SAVE_PDF_REQUEST && requestCode != SAVE_PDF_DOWNLOADS_REQUEST) {
            super.onActivityResult(requestCode, resultCode, data)
            return
        }
        val request = pendingPdfSave
        pendingPdfSave = null
        if (request == null) return
        val destination = data?.data
        if (resultCode != RESULT_OK || destination == null) {
            request.result.success(request.cancelValue)
            return
        }
        edgeExecutor.execute {
            try {
                request.source.inputStream().buffered().use { input ->
                    val output = contentResolver.openOutputStream(destination, "w")
                        ?: throw IllegalStateException("Android could not open the selected location.")
                    output.buffered().use { input.copyTo(it) }
                }
                mainHandler.post { request.result.success(request.successValue) }
            } catch (error: Throwable) {
                mainHandler.post {
                    request.result.error(
                        "PDF_SAVE_FAILED",
                        error.message ?: "Could not save the PDF to this location.",
                        null,
                    )
                }
            }
        }
    }

    private fun savePdfToDevice(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        if (pendingPdfSave != null) {
            result.error("SAVE_IN_PROGRESS", "A PDF save is already in progress.", null)
            return
        }
        val path = call.argument<String>("path")
        val fileName = call.argument<String>("fileName")
        val source = path?.let(::File)
        if (source == null || !source.isFile || source.length() == 0L) {
            result.error("PDF_NOT_FOUND", "The PDF file could not be found or is empty.", null)
            return
        }
        val safeName = (fileName ?: "ScanFlow.pdf")
            .replace('/', '_')
            .replace('\\', '_')
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "application/pdf"
            putExtra(Intent.EXTRA_TITLE, if (safeName.endsWith(".pdf", true)) safeName else "$safeName.pdf")
        }
        try {
            pendingPdfSave = PendingPdfSave(source, result)
            startActivityForResult(intent, SAVE_PDF_REQUEST)
        } catch (error: Throwable) {
            pendingPdfSave = null
            result.error("PDF_PICKER_UNAVAILABLE", error.message ?: "Android could not open the save picker.", null)
        }
    }

    private fun savePdfToDownloads(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        val path = call.argument<String>("path")
        val requestedName = call.argument<String>("fileName") ?: "ScanFlow.pdf"
        val source = path?.let(::File)
        if (source == null || !source.isFile || source.length() == 0L) {
            result.error("PDF_NOT_FOUND", "The PDF file could not be found or is empty.", null)
            return
        }
        val safeName = requestedName
            .replace('/', '_')
            .replace('\\', '_')
            .let { if (it.endsWith(".pdf", true)) it else "$it.pdf" }

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            if (pendingPdfSave != null) {
                result.error("SAVE_IN_PROGRESS", "A PDF save is already in progress.", null)
                return
            }
            val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                addCategory(Intent.CATEGORY_OPENABLE)
                type = "application/pdf"
                putExtra(Intent.EXTRA_TITLE, safeName)
            }
            try {
                pendingPdfSave = PendingPdfSave(
                    source = source,
                    result = result,
                    successValue = "Saved to the location you selected",
                    cancelValue = null,
                )
                startActivityForResult(intent, SAVE_PDF_DOWNLOADS_REQUEST)
            } catch (error: Throwable) {
                pendingPdfSave = null
                result.error("PDF_PICKER_UNAVAILABLE", error.message ?: "Android could not open the save picker.", null)
            }
            return
        }

        edgeExecutor.execute {
            var uri: Uri? = null
            try {
                val relativePath = "${Environment.DIRECTORY_DOWNLOADS}/ScanFlow/"
                val displayName = uniqueDownloadName(safeName, relativePath)
                val values = ContentValues().apply {
                    put(MediaStore.MediaColumns.DISPLAY_NAME, displayName)
                    put(MediaStore.MediaColumns.MIME_TYPE, "application/pdf")
                    put(MediaStore.MediaColumns.RELATIVE_PATH, relativePath)
                    put(MediaStore.MediaColumns.IS_PENDING, 1)
                }
                val targetUri = contentResolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                    ?: throw IllegalStateException("Could not create the PDF in Downloads/ScanFlow.")
                uri = targetUri
                val output = contentResolver.openOutputStream(targetUri, "w")
                    ?: throw IllegalStateException("Could not write the PDF to Downloads/ScanFlow.")
                source.inputStream().buffered().use { input ->
                    output.buffered().use { destination -> input.copyTo(destination) }
                }
                val ready = ContentValues().apply {
                    put(MediaStore.MediaColumns.IS_PENDING, 0)
                }
                contentResolver.update(targetUri, ready, null, null)
                mainHandler.post { result.success("Downloads/ScanFlow/$displayName") }
            } catch (error: Throwable) {
                uri?.let { contentResolver.delete(it, null, null) }
                mainHandler.post {
                    result.error(
                        "PDF_DOWNLOAD_SAVE_FAILED",
                        error.message ?: "Could not save the PDF to Downloads/ScanFlow.",
                        null,
                    )
                }
            }
        }
    }

    private fun uniqueDownloadName(fileName: String, relativePath: String): String {
        val base = fileName.substringBeforeLast('.', fileName)
        val extension = fileName.substringAfterLast('.', "pdf")
        var candidate = fileName
        var suffix = 2
        while (true) {
            val cursor = contentResolver.query(
                MediaStore.Downloads.EXTERNAL_CONTENT_URI,
                arrayOf(MediaStore.MediaColumns._ID),
                "${MediaStore.MediaColumns.DISPLAY_NAME} = ? AND ${MediaStore.MediaColumns.RELATIVE_PATH} = ?",
                arrayOf(candidate, relativePath),
                null,
            )
            val exists = cursor?.use { it.moveToFirst() } ?: false
            if (!exists) return candidate
            candidate = "$base ($suffix).$extension"
            suffix++
        }
    }

    private fun sharePdf(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        val path = call.argument<String>("path")
        val title = call.argument<String>("title") ?: "ScanFlow PDF"
        val source = path?.let(::File)
        if (source == null || !source.isFile || source.length() == 0L) {
            result.error("PDF_NOT_FOUND", "The PDF file could not be found or is empty.", null)
            return
        }
        edgeExecutor.execute {
            try {
                val shareDirectory = File(cacheDir, "share_plus")
                if (!shareDirectory.exists() && !shareDirectory.mkdirs()) {
                    throw IllegalStateException("Could not prepare the PDF for sharing.")
                }
                val safeName = source.name.replace('/', '_').replace('\\', '_')
                val shareCopy = File(shareDirectory, safeName)
                source.inputStream().buffered().use { input ->
                    shareCopy.outputStream().buffered().use { output -> input.copyTo(output) }
                }
                val uri = FileProvider.getUriForFile(
                    this,
                    "$packageName.flutter.share_provider",
                    shareCopy,
                )
                mainHandler.post {
                    try {
                        val sendIntent = Intent(Intent.ACTION_SEND).apply {
                            type = "application/pdf"
                            putExtra(Intent.EXTRA_STREAM, uri)
                            putExtra(Intent.EXTRA_SUBJECT, title)
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            clipData = ClipData.newUri(contentResolver, title, uri)
                        }
                        startActivity(Intent.createChooser(sendIntent, title))
                        result.success(null)
                    } catch (error: Throwable) {
                        result.error("PDF_SHARE_FAILED", error.message ?: "Android could not open the share menu.", null)
                    }
                }
            } catch (error: Throwable) {
                mainHandler.post {
                    result.error("PDF_SHARE_FAILED", error.message ?: "Could not prepare the PDF for sharing.", null)
                }
            }
        }
    }

    override fun onDestroy() {
        pendingPdfSave?.result?.error("SAVE_CANCELLED", "The app closed before the PDF was saved.", null)
        pendingPdfSave = null
        edgeExecutor.shutdown()
        super.onDestroy()
    }

    private fun correctDocumentEdges(bytes: ByteArray): ByteArray? {
        if (!OpenCVLoader.initLocal()) {
            throw IllegalStateException("OpenCV could not be initialized on this device.")
        }
        val encoded = MatOfByte()
        encoded.fromArray(*bytes)
        val source = Imgcodecs.imdecode(encoded, Imgcodecs.IMREAD_COLOR)
        encoded.release()
        if (source.empty() || source.cols() < 80 || source.rows() < 80) {
            source.release()
            return null
        }

        var reduced: Mat? = null
        var gray: Mat? = null
        var blurred: Mat? = null
        var edges: Mat? = null
        var hierarchy: Mat? = null
        var transform: Mat? = null
        var corrected: Mat? = null
        var sourceCorners: MatOfPoint2f? = null
        var destinationCorners: MatOfPoint2f? = null
        var encodedResult: MatOfByte? = null
        var quality: MatOfInt? = null
        try {
            val scale = if (source.cols() > 1600) 1600.0 / source.cols() else 1.0
            if (scale < 1.0) {
                reduced = Mat()
                Imgproc.resize(
                    source,
                    reduced,
                    Size((source.cols() * scale).toInt().toDouble(), (source.rows() * scale).toInt().toDouble()),
                    0.0,
                    0.0,
                    Imgproc.INTER_AREA,
                )
            } else {
                reduced = source
            }
            gray = Mat()
            Imgproc.cvtColor(reduced, gray, Imgproc.COLOR_BGR2GRAY)
            blurred = Mat()
            Imgproc.GaussianBlur(gray, blurred, Size(5.0, 5.0), 0.0)
            edges = Mat()
            Imgproc.Canny(blurred, edges, 35.0, 120.0)
            val kernel = Imgproc.getStructuringElement(Imgproc.MORPH_RECT, Size(5.0, 5.0))
            try {
                Imgproc.morphologyEx(edges, edges, Imgproc.MORPH_CLOSE, kernel)
            } finally {
                kernel.release()
            }
            hierarchy = Mat()
            val contours = ArrayList<MatOfPoint>()
            Imgproc.findContours(edges, contours, hierarchy, Imgproc.RETR_EXTERNAL, Imgproc.CHAIN_APPROX_SIMPLE)

            var best: Array<Point>? = null
            var bestArea = reduced.cols().toDouble() * reduced.rows() * 0.08
            try {
                for (contour in contours) {
                    val contourPoints = MatOfPoint2f(*contour.toArray())
                    try {
                        val perimeter = Imgproc.arcLength(contourPoints, true)
                        for (epsilon in doubleArrayOf(0.012, 0.018, 0.025, 0.035)) {
                            val approximation = MatOfPoint2f()
                            try {
                                Imgproc.approxPolyDP(contourPoints, approximation, perimeter * epsilon, true)
                                val points = approximation.toArray()
                                if (points.size == 4) {
                                    val polygon = MatOfPoint(*points)
                                    try {
                                        val area = abs(Imgproc.contourArea(polygon))
                                        val touchesFrame = points.any {
                                            it.x < 2.0 || it.y < 2.0 ||
                                                it.x >= reduced.cols() - 2.0 ||
                                                it.y >= reduced.rows() - 2.0
                                        }
                                        val frameArea = reduced.cols().toDouble() * reduced.rows()
                                        if (!touchesFrame && area < frameArea * 0.985 &&
                                            Imgproc.isContourConvex(polygon) && area > bestArea) {
                                            bestArea = area
                                            best = points
                                        }
                                    } finally {
                                        polygon.release()
                                    }
                                }
                            } finally {
                                approximation.release()
                            }
                        }
                    } finally {
                        contourPoints.release()
                    }
                    contour.release()
                }
            } finally {
                hierarchy.release()
                hierarchy = null
            }

            val points = best ?: return null
            val ordered = orderCorners(points)
            val multiplier = 1.0 / scale
            val mapped = ordered.map { Point(it.x * multiplier, it.y * multiplier) }.toTypedArray()
            val width = max(distance(mapped[0], mapped[1]), distance(mapped[3], mapped[2]))
                .toInt().coerceIn(1, source.cols())
            val height = max(distance(mapped[0], mapped[3]), distance(mapped[1], mapped[2]))
                .toInt().coerceIn(1, source.rows())
            if (width < 80 || height < 80) return null

            val target = arrayOf(Point(0.0, 0.0), Point(width - 1.0, 0.0), Point(width - 1.0, height - 1.0), Point(0.0, height - 1.0))
            sourceCorners = MatOfPoint2f(*mapped)
            destinationCorners = MatOfPoint2f(*target)
            transform = Imgproc.getPerspectiveTransform(sourceCorners, destinationCorners)
            corrected = Mat()
            Imgproc.warpPerspective(source, corrected, transform, Size(width.toDouble(), height.toDouble()))
            encodedResult = MatOfByte()
            quality = MatOfInt(Imgcodecs.IMWRITE_JPEG_QUALITY, 94)
            if (!Imgcodecs.imencode(".jpg", corrected, encodedResult, quality)) return null
            return encodedResult.toArray()
        } finally {
            if (reduced !== source) reduced?.release()
            gray?.release()
            blurred?.release()
            edges?.release()
            hierarchy?.release()
            transform?.release()
            corrected?.release()
            sourceCorners?.release()
            destinationCorners?.release()
            encodedResult?.release()
            quality?.release()
            source.release()
        }
    }

    private fun orderCorners(points: Array<Point>): List<Point> {
        val topLeft = points.minBy { it.x + it.y }
        val bottomRight = points.maxBy { it.x + it.y }
        val topRight = points.minBy { it.y - it.x }
        val bottomLeft = points.maxBy { it.y - it.x }
        return listOf(topLeft, topRight, bottomRight, bottomLeft)
    }

    private fun distance(first: Point, second: Point): Double = hypot(first.x - second.x, first.y - second.y)
}
