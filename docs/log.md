PS C:\Users\Moein\Documents\Codes\astrix_assist> flutter run -d R92Y704M3XT
Launching lib\main.dart on SM X216B in debug mode...
Running Gradle task 'assembleDebug'...                             10.1s
√ Built build\app\outputs\flutter-apk\app-debug.apk
Installing build\app\outputs\flutter-apk\app-debug.apk...           8.3s
D/FlutterJNI(28766): Beginning load of flutter...
D/FlutterJNI(28766): flutter (null) was loaded normally!
I/flutter (28766): [IMPORTANT:flutter/shell/platform/android/android_context_vk_impeller.cc(62)] Using the Impeller rendering backend (Vulkan).
Syncing files to device SM X216B...                                104ms

Flutter run key commands.
r Hot reload. 
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).

A Dart VM Service on SM X216B is available at: http://127.0.0.1:9419/ZimERlzMS5k=/
The Flutter DevTools debugger and profiler on SM X216B is available at: http://127.0.0.1:9419/ZimERlzMS5k=/devtools/?uri=ws://127.0.0.1:9419/ZimERlzMS5k=/ws
D/HWUI    (28766): HWUI - treat SMPTE_170M as sRGB
I/IDS_TAG (28766): Closing IDS observe window
I/IDS_TAG (28766): Getting Shared Preference for android.app.Application@1fde585 uid = 10318
I/IDS_TAG (28766): IDS count updated to 1 for android.app.Application@1fde585
I/WindowExtensionsImpl(28766): Initializing Window Extensions, vendor API level=6, activity embedding enabled=true
I/SurfaceView@a7bde90(28766): onWindowVisibilityChanged(0) true io.flutter.embedding.android.FlutterSurfaceView{a7bde90 V.E...... ......I. 0,0-0,0} of VRI[MainActivity]@41e683e
D/SurfaceView(28766): 175890064 updateSurface: has no frame
E/e.astrix_assist(28766): Unable to open libpenguin.so: dlopen failed: library "libpenguin.so" not found.
I/BLASTBufferQueue_Java(28766): new BLASTBufferQueue, mName= VRI[MainActivity]@41e683e mNativeObject= 0xb400006f32f69500 sc.mNativeObject= 0xb400006f2d37ccc0 caller= android.view.ViewRootImpl.updateBlastSurfaceIfNeeded:3397 android.view.ViewRootImpl.relayoutWindow:11361 android.view.ViewRootImpl.performTraversals:4544 android.view.ViewRootImpl.doTraversal:3708 android.view.ViewRootImpl$TraversalRunnable.run:12542 android.view.Choreographer$CallbackRecord.run:1751 android.view.Choreographer$CallbackRecord.run:1760 android.view.Choreographer.doCallbacks:1216 android.view.Choreographer.doFrame:1142 android.view.Choreographer$FrameDisplayEventReceiver.run:1707
I/BLASTBufferQueue_Java(28766): update, w= 1200 h= 1920 mName = VRI[MainActivity]@41e683e mNativeObject= 0xb400006f32f69500 sc.mNativeObject= 0xb400006f2d37ccc0 format= -3 caller= android.graphics.BLASTBufferQueue.<init>:88 android.view.ViewRootImpl.updateBlastSurfaceIfNeeded:3397 android.view.ViewRootImpl.relayoutWindow:11361 android.view.ViewRootImpl.performTraversals:4544 android.view.ViewRootImpl.doTraversal:3708 android.view.ViewRootImpl$TraversalRunnable.run:12542      
W/libc    (28766): Access denied finding property "vendor.display.enable_optimal_refresh_rate"
W/libc    (28766): Access denied finding property "vendor.gpp.create_frc_extension"
I/VRI[MainActivity]@41e683e(28766): Relayout returned: old=(0,0,1200,1920) new=(0,0,1200,1920) relayoutAsync=false req=(1200,1920)0 dur=17 res=0x3 s={true 0xb400006eda64d800} ch=true seqId=0
D/VRI[MainActivity]@41e683e(28766): mThreadedRenderer.initialize() mSurface={isValid=true 0xb400006eda64d800} hwInitialized=true
D/SurfaceView(28766): 175890064 updateSurface: has no frame
I/SurfaceView@a7bde90(28766): windowStopped(false) true io.flutter.embedding.android.FlutterSurfaceView{a7bde90 V.E...... ......ID 0,0-1200,1920} of VRI[MainActivity]@41e683e
D/SurfaceView(28766): 175890064 updateSurface: has no frame
D/VRI[MainActivity]@41e683e(28766): reportNextDraw android.view.ViewRootImpl.performTraversals:5193 android.view.ViewRootImpl.doTraversal:3708 android.view.ViewRootImpl$TraversalRunnable.run:12542 android.view.Choreographer$CallbackRecord.run:1751 android.view.Choreographer$CallbackRecord.run:1760
I/SurfaceView(28766): 175890064 Changes: creating=true format=true size=true visible=true alpha=false hint=false visible=true left=true top=true z=false attached=true lifecycleStrategy=false
I/BLASTBufferQueue_Java(28766): update, w= 1200 h= 1920 mName = null mNativeObject= 0xb400006f32f69800 sc.mNativeObject= 0xb400006f2d37d200 format= 4 caller= android.view.SurfaceView.createBlastSurfaceControls:1642 android.view.SurfaceView.updateSurface:1318 android.view.SurfaceView.lambda$new$0:268 android.view.SurfaceView.$r8$lambda$NfZyM_TG8F8lqzaOVZ7noREFjzU:0 android.view.SurfaceView$$ExternalSyntheticLambda1.onPreDraw:0 android.view.ViewTreeObserver.dispatchOnPreDraw:1226
I/SurfaceView(28766): 175890064 Cur surface: Surface(name=null mNativeObject=0)/@0x84e095
I/SurfaceView@a7bde90(28766): pST: sr = Rect(0, 0 - 1200, 1920) sw = 1200 sh = 1920
D/SurfaceView(28766): 175890064 performSurfaceTransaction RenderWorker position = [0, 0, 1200, 1920] surfaceSize = 1200x1920
W/libc    (28766): Access denied finding property "vendor.display.enable_optimal_refresh_rate"
W/libc    (28766): Access denied finding property "vendor.gpp.create_frc_extension"
I/SurfaceView@a7bde90(28766): updateSurface: mVisible = true mSurface.isValid() = true
I/SurfaceView@a7bde90(28766): updateSurface: mSurfaceCreated = false surfaceChanged = true visibleChanged = true
I/SurfaceView(28766): 175890064 visibleChanged -- surfaceCreated
I/SurfaceView@a7bde90(28766): surfaceCreated 1 #8 io.flutter.embedding.android.FlutterSurfaceView{a7bde90 V.E...... ......ID 0,0-1200,1920}
E/qdgralloc(28766): GetGpuPixelFormat: No map for format: 0x38
E/AdrenoUtils(28766): <validate_memory_layout_input_parmas:1970>: Unknown Format 0
E/AdrenoUtils(28766): <adreno_init_memory_layout:4720>: Memory Layout input parameter validation failed!
W/qdgralloc(28766): GetGpuResourceSizeAndDimensions Graphics metadata init failed
E/Gralloc4(28766): isSupported(1, 1, 56, 1, ...) failed with 7
E/GraphicBufferAllocator(28766): Failed to allocate (4 x 4) layerCount 1 format 56 usage b00: 7
E/AHardwareBuffer(28766): GraphicBuffer(w=4, h=4, lc=1) failed (Unknown error -7), handle=0x0
E/qdgralloc(28766): GetGpuPixelFormat: No map for format: 0x3b
E/AdrenoUtils(28766): <validate_memory_layout_input_parmas:1970>: Unknown Format 0
E/AdrenoUtils(28766): <adreno_init_memory_layout:4720>: Memory Layout input parameter validation failed!
W/qdgralloc(28766): GetGpuResourceSizeAndDimensions Graphics metadata init failed
E/Gralloc4(28766): isSupported(1, 1, 59, 1, ...) failed with 7
E/GraphicBufferAllocator(28766): Failed to allocate (4 x 4) layerCount 1 format 59 usage b00: 7
E/AHardwareBuffer(28766): GraphicBuffer(w=4, h=4, lc=1) failed (Unknown error -7), handle=0x0
E/qdgralloc(28766): GetGpuPixelFormat: No map for format: 0x38
E/AdrenoUtils(28766): <validate_memory_layout_input_parmas:1970>: Unknown Format 0
E/AdrenoUtils(28766): <adreno_init_memory_layout:4720>: Memory Layout input parameter validation failed!
W/qdgralloc(28766): GetGpuResourceSizeAndDimensions Graphics metadata init failed
E/Gralloc4(28766): isSupported(1, 1, 56, 1, ...) failed with 7
E/GraphicBufferAllocator(28766): Failed to allocate (4 x 4) layerCount 1 format 56 usage b00: 7
E/AHardwareBuffer(28766): GraphicBuffer(w=4, h=4, lc=1) failed (Unknown error -7), handle=0x0
E/qdgralloc(28766): GetGpuPixelFormat: No map for format: 0x3b
E/AdrenoUtils(28766): <validate_memory_layout_input_parmas:1970>: Unknown Format 0
E/AdrenoUtils(28766): <adreno_init_memory_layout:4720>: Memory Layout input parameter validation failed!
W/qdgralloc(28766): GetGpuResourceSizeAndDimensions Graphics metadata init failed
E/Gralloc4(28766): isSupported(1, 1, 59, 1, ...) failed with 7
E/GraphicBufferAllocator(28766): Failed to allocate (4 x 4) layerCount 1 format 59 usage b00: 7
E/AHardwareBuffer(28766): GraphicBuffer(w=4, h=4, lc=1) failed (Unknown error -7), handle=0x0
I/SurfaceView(28766): 175890064 surfaceChanged -- format=4 w=1200 h=1920
I/SurfaceView@a7bde90(28766): surfaceChanged (1200,1920) 1 #8 io.flutter.embedding.android.FlutterSurfaceView{a7bde90 V.E...... ......ID 0,0-1200,1920}
I/SurfaceView(28766): 175890064 surfaceRedrawNeeded
V/SurfaceView(28766): Layout: x=0 y=0 w=1200 h=1920, frame=Rect(0, 0 - 1200, 1920)
D/VRI[MainActivity]@41e683e(28766): Canceling draw. cancelDueToPreDrawListener=true cancelDueToSync=false
D/HWUI    (28766): CacheManager::trimMemory(20)
I/VRI[MainActivity]@41e683e(28766): stopped(true) old = false
D/VRI[MainActivity]@41e683e(28766): WindowStopped on com.example.astrix_assist/com.example.astrix_assist.MainActivity set to true
D/HWUI    (28766): CacheManager::trimMemory(20)
I/SurfaceView@a7bde90(28766): windowStopped(true) false io.flutter.embedding.android.FlutterSurfaceView{a7bde90 V.E...... ......ID 0,0-1200,1920} of VRI[MainActivity]@41e683e
I/SurfaceView(28766): 175890064 Changes: creating=false format=false size=false visible=true alpha=false hint=false visible=true left=false top=false z=false attached=true lifecycleStrategy=false
I/SurfaceView(28766): 175890064 Cur surface: Surface(name=null mNativeObject=-5476376670756343808)/@0x84e095
I/SurfaceView(28766): 175890064 surfaceDestroyed
I/SurfaceView@a7bde90(28766): surfaceDestroyed callback.size 1 #1 io.flutter.embedding.android.FlutterSurfaceView{a7bde90 V.E...... ......ID 0,0-1200,1920}
I/SurfaceView@a7bde90(28766): updateSurface: mVisible = false mSurface.isValid() = true
I/SurfaceView@a7bde90(28766): releaseSurfaces: viewRoot = VRI[MainActivity]@41e683e
V/SurfaceView(28766): Layout: x=0 y=0 w=1200 h=1920, frame=Rect(0, 0 - 1200, 1920)
D/SurfaceView@a7bde90(28766): updateSurface: surface is not valid
I/SurfaceView@a7bde90(28766): releaseSurfaces: viewRoot = VRI[MainActivity]@41e683e
I/SurfaceView@a7bde90(28766): onWindowVisibilityChanged(4) false io.flutter.embedding.android.FlutterSurfaceView{a7bde90 G.E...... ......ID 0,0-1200,1920} of VRI[MainActivity]@41e683e
D/SurfaceView@a7bde90(28766): updateSurface: surface is not valid
I/SurfaceView@a7bde90(28766): releaseSurfaces: viewRoot = VRI[MainActivity]@41e683e
D/HWUI    (28766): CacheManager::trimMemory(20)
I/VRI[MainActivity]@41e683e(28766): Relayout returned: old=(0,0,1200,1920) new=(0,0,1200,1920) relayoutAsync=false req=(1200,1920)4 dur=6 res=0x2 s={false 0x0} ch=false seqId=0
D/SurfaceView@a7bde90(28766): updateSurface: surface is not valid
I/SurfaceView@a7bde90(28766): releaseSurfaces: viewRoot = VRI[MainActivity]@41e683e
D/VRI[MainActivity]@41e683e(28766): applyTransactionOnDraw applyImmediately
D/VRI[MainActivity]@41e683e(28766): Not drawing due to not visible. Reason=View.INVISIBLE
D/VRI[MainActivity]@41e683e(28766): Pending transaction will not be applied in sync with a draw due to view not visible
I/e.astrix_assist(28766): Compiler allocated 7599KB to compile void android.view.ViewRootImpl.performTraversals()
I/VRI[MainActivity]@41e683e(28766): handleAppVisibility mAppVisible = true visible = false
D/ProfileInstaller(28766): Installing profile for com.example.astrix_assist
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   NotificationService.initialize (package:astrix_assist/core/notification_service.dart:48:14)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 NotificationService initialized successfully
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   BackgroundServiceManager.initialize (package:astrix_assist/core/background_service_manager.dart:22:14)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 BackgroundServiceManager initialized successfully
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/VRI[MainActivity]@41e683e(28766): onDisplayChanged oldDisplayState=1 newDisplayState=2
I/VRI[MainActivity]@41e683e(28766): onDisplayChanged oldDisplayState=2 newDisplayState=2
D/PhoneWindow(28766): forceLight changed to false [com.example.astrix_assist/com.example.astrix_assist.MainActivity] from com.android.internal.policy.PhoneWindow.updateForceLightNavigationBar:4536 com.android.internal.policy.PhoneWindow.setNavigationBarColor:4227 io.flutter.plugin.platform.PlatformPlugin.setSystemChromeSystemUIOverlayStyle:503 io.flutter.plugin.platform.PlatformPlugin.access$700:36 io.flutter.plugin.platform.PlatformPlugin$1.setSystemUiOverlayStyle:123       
I/VRI[MainActivity]@41e683e(28766): handleAppVisibility mAppVisible = false visible = true
I/VRI[MainActivity]@41e683e(28766): stopped(false) old = true
D/VRI[MainActivity]@41e683e(28766): WindowStopped on com.example.astrix_assist/com.example.astrix_assist.MainActivity set to false
D/SurfaceView@a7bde90(28766): updateSurface: surface is not valid
I/SurfaceView@a7bde90(28766): releaseSurfaces: viewRoot = VRI[MainActivity]@41e683e
D/VRI[MainActivity]@41e683e(28766): applyTransactionOnDraw applyImmediately
I/InsetsController(28766): onStateChanged: host=com.example.astrix_assist/com.example.astrix_assist.MainActivity, from=android.view.ViewRootImpl.handleResized:2789, state=InsetsState: {mDisplayFrame=Rect(0, 0 - 1200, 1920), mDisplayCutout=DisplayCutout{insets=Rect(0, 0 - 0, 0) waterfall=Insets{left=0, top=0, right=0, bottom=0} boundingRect={Bounds=[Rect(0, 0 - 0, 0), Rect(0, 0 - 0, 0), Rect(0, 0 - 0, 0), Rect(0, 0 - 0, 0)]} cutoutPathParserInfo={CutoutPathParserInfo{displayWidth=0 displayHeight=0 physicalDisplayWidth=0 physicalDisplayHeight=0 density={0.0} cutoutSpec={} rotation={0} scale={0.0} physicalPixelDisplaySizeRatio={0.0}}} sideOverrides=null}, mRoundedCorners=RoundedCorners{[RoundedCorner{position=TopLeft, radius=20, center=Point(20, 20)}, RoundedCorner{position=TopRight, radius=20, center=Point(1180, 20)}, RoundedCorner{position=BottomRight, radius=20, center=Point(1180, 1900)}, RoundedCorner{position=BottomLeft, radius=20, center=Point(20, 1900)}]}  mRoundedCornerFrame=Rect(0, 0 - 1200, 1920), mPrivacyIndicatorBounds=PrivacyIndicatorBounds {static bounds=Rect(1134, 0 - 1200, 36) rotation=0}, mDisplayShape=DisplayShape{ spec=-311912193 displayWidth=1200 displayHeight=1920 physicalPixelDisplaySizeRatio=1.0 rotation=0 offsetX=0 offsetY=0 scale=1.0}, mSources= { InsetsSource: {aefa0001 mType=navigationBars mFrame=[0,1897][1200,1920] mVisible=true mFlags=SUPPRESS_SCRIM mSideHint=BOTTOM mBoundingRects=null}, InsetsSource: {aefa0004 mType=systemGestures mFrame=[0,0][45,1920] mVisible=true mFlags= mSideHint=LEFT mBoundingRects=null}, InsetsSource: {aefa0005 mType=mandatorySystemGestures mFrame=[0,1872][1200,1920] mVisible=true mFlags= mSideHint=BOTTOM mBoundingRects=null}, InsetsSource: {aefa0006 mType=tappableElement mFrame=[0,0][0,0] mVisible=true mFlags= mSideHint=NONE mBoundingRects=null}, InsetsSource: {aefa0024 mType=systemGestures mFrame=[1155,0][1200,1920] mVisible=true mFlags= mSideHint=RIGHT mBoundingRects=null}, InsetsSource: {3 mType=ime mFrame=[0,0][0,0] mVisible=false mFlags= mSideHint=NONE mBoundingRects=null}, InsetsSource: {61720000 mType=statusBars mFrame=[0,0][1200,36] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null}, InsetsSource: {61720005 mType=mandatorySystemGestures mFrame=[0,0][1200,36] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null}, InsetsSource: {61720006 mType=tappableElement mFrame=[0,0][1200,36] mVisible=true mFlags= mSideHint=TOP mBoundingRects=null} }
I/VRI[MainActivity]@41e683e(28766): handleResized, frames=ClientWindowFrames{frame=[0,0][1200,1920] display=[0,0][1200,1920] parentFrame=[0,0][0,0]} displayId=0 dragResizing=false compatScale=1.0 frameChanged=false attachedFrameChanged=false configChanged=true displayChanged=false compatScaleChanged=false dragResizingChanged=false
I/VRI[MainActivity]@41e683e(28766): handleResized mSyncSeqId = 0
I/SurfaceView@a7bde90(28766): onWindowVisibilityChanged(0) false io.flutter.embedding.android.FlutterSurfaceView{a7bde90 V.E...... ......ID 0,0-1200,1920} of VRI[MainActivity]@41e683e
D/SurfaceView@a7bde90(28766): updateSurface: surface is not valid
I/SurfaceView@a7bde90(28766): releaseSurfaces: viewRoot = VRI[MainActivity]@41e683e
D/VRI[MainActivity]@41e683e(28766): applyTransactionOnDraw applyImmediately
I/BLASTBufferQueue_Java(28766): new BLASTBufferQueue, mName= VRI[MainActivity]@41e683e mNativeObject= 0xb400006edb619200 sc.mNativeObject= 0xb400006ea159bdc0 caller= android.view.ViewRootImpl.updateBlastSurfaceIfNeeded:3397 android.view.ViewRootImpl.relayoutWindow:11361 android.view.ViewRootImpl.performTraversals:4544 android.view.ViewRootImpl.doTraversal:3708 android.view.ViewRootImpl$TraversalRunnable.run:12542 android.view.Choreographer$CallbackRecord.run:1751 android.view.Choreographer$CallbackRecord.run:1760 android.view.Choreographer.doCallbacks:1216 android.view.Choreographer.doFrame:1142 android.view.Choreographer$FrameDisplayEventReceiver.run:1707
I/BLASTBufferQueue_Java(28766): update, w= 1200 h= 1920 mName = VRI[MainActivity]@41e683e mNativeObject= 0xb400006edb619200 sc.mNativeObject= 0xb400006ea159bdc0 format= -3 caller= android.graphics.BLASTBufferQueue.<init>:88 android.view.ViewRootImpl.updateBlastSurfaceIfNeeded:3397 android.view.ViewRootImpl.relayoutWindow:11361 android.view.ViewRootImpl.performTraversals:4544 android.view.ViewRootImpl.doTraversal:3708 android.view.ViewRootImpl$TraversalRunnable.run:12542      
W/libc    (28766): Access denied finding property "vendor.display.enable_optimal_refresh_rate"
W/libc    (28766): Access denied finding property "vendor.gpp.create_frc_extension"
I/VRI[MainActivity]@41e683e(28766): Relayout returned: old=(0,0,1200,1920) new=(0,0,1200,1920) relayoutAsync=false req=(1200,1920)0 dur=25 res=0x3 s={true 0xb400006edb38a800} ch=true seqId=0
D/VRI[MainActivity]@41e683e(28766): mThreadedRenderer.initialize() mSurface={isValid=true 0xb400006edb38a800} hwInitialized=true
I/SurfaceView@a7bde90(28766): windowStopped(false) true io.flutter.embedding.android.FlutterSurfaceView{a7bde90 V.E...... ......ID 0,0-1200,1920} of VRI[MainActivity]@41e683e
I/SurfaceView(28766): 175890064 Changes: creating=true format=false size=false visible=true alpha=false hint=false visible=true left=false top=false z=false attached=true lifecycleStrategy=false
I/BLASTBufferQueue_Java(28766): update, w= 1200 h= 1920 mName = null mNativeObject= 0xb400006edb619b00 sc.mNativeObject= 0xb400006ea159a680 format= 4 caller= android.view.SurfaceView.createBlastSurfaceControls:1642 android.view.SurfaceView.updateSurface:1318 android.view.SurfaceView.setWindowStopped:474 android.view.SurfaceView.surfaceCreated:2172 android.view.ViewRootImpl.notifySurfaceCreated:3312 android.view.ViewRootImpl.performTraversals:5036
I/SurfaceView(28766): 175890064 Cur surface: Surface(name=null mNativeObject=0)/@0x84e095
I/SurfaceView@a7bde90(28766): pST: sr = Rect(0, 0 - 1200, 1920) sw = 1200 sh = 1920
D/SurfaceView(28766): 175890064 performSurfaceTransaction RenderWorker position = [0, 0, 1200, 1920] surfaceSize = 1200x1920
W/libc    (28766): Access denied finding property "vendor.display.enable_optimal_refresh_rate"
W/libc    (28766): Access denied finding property "vendor.gpp.create_frc_extension"
I/SurfaceView@a7bde90(28766): updateSurface: mVisible = true mSurface.isValid() = true
I/SurfaceView@a7bde90(28766): updateSurface: mSurfaceCreated = false surfaceChanged = true visibleChanged = true
I/SurfaceView(28766): 175890064 visibleChanged -- surfaceCreated
I/SurfaceView@a7bde90(28766): surfaceCreated 1 #1 io.flutter.embedding.android.FlutterSurfaceView{a7bde90 V.E...... ......ID 0,0-1200,1920}
E/qdgralloc(28766): GetGpuPixelFormat: No map for format: 0x38
E/AdrenoUtils(28766): <validate_memory_layout_input_parmas:1970>: Unknown Format 0
E/AdrenoUtils(28766): <adreno_init_memory_layout:4720>: Memory Layout input parameter validation failed!
W/qdgralloc(28766): GetGpuResourceSizeAndDimensions Graphics metadata init failed
E/Gralloc4(28766): isSupported(1, 1, 56, 1, ...) failed with 7
E/GraphicBufferAllocator(28766): Failed to allocate (4 x 4) layerCount 1 format 56 usage b00: 7
E/AHardwareBuffer(28766): GraphicBuffer(w=4, h=4, lc=1) failed (Unknown error -7), handle=0x0
E/qdgralloc(28766): GetGpuPixelFormat: No map for format: 0x3b
E/AdrenoUtils(28766): <validate_memory_layout_input_parmas:1970>: Unknown Format 0
E/AdrenoUtils(28766): <adreno_init_memory_layout:4720>: Memory Layout input parameter validation failed!
W/qdgralloc(28766): GetGpuResourceSizeAndDimensions Graphics metadata init failed
E/Gralloc4(28766): isSupported(1, 1, 59, 1, ...) failed with 7
E/GraphicBufferAllocator(28766): Failed to allocate (4 x 4) layerCount 1 format 59 usage b00: 7
E/AHardwareBuffer(28766): GraphicBuffer(w=4, h=4, lc=1) failed (Unknown error -7), handle=0x0
E/qdgralloc(28766): GetGpuPixelFormat: No map for format: 0x38
E/AdrenoUtils(28766): <validate_memory_layout_input_parmas:1970>: Unknown Format 0
E/AdrenoUtils(28766): <adreno_init_memory_layout:4720>: Memory Layout input parameter validation failed!
W/qdgralloc(28766): GetGpuResourceSizeAndDimensions Graphics metadata init failed
E/Gralloc4(28766): isSupported(1, 1, 56, 1, ...) failed with 7
E/GraphicBufferAllocator(28766): Failed to allocate (4 x 4) layerCount 1 format 56 usage b00: 7
E/AHardwareBuffer(28766): GraphicBuffer(w=4, h=4, lc=1) failed (Unknown error -7), handle=0x0
E/qdgralloc(28766): GetGpuPixelFormat: No map for format: 0x3b
E/AdrenoUtils(28766): <validate_memory_layout_input_parmas:1970>: Unknown Format 0
E/AdrenoUtils(28766): <adreno_init_memory_layout:4720>: Memory Layout input parameter validation failed!
W/qdgralloc(28766): GetGpuResourceSizeAndDimensions Graphics metadata init failed
E/Gralloc4(28766): isSupported(1, 1, 59, 1, ...) failed with 7
E/GraphicBufferAllocator(28766): Failed to allocate (4 x 4) layerCount 1 format 59 usage b00: 7
E/AHardwareBuffer(28766): GraphicBuffer(w=4, h=4, lc=1) failed (Unknown error -7), handle=0x0
I/SurfaceView(28766): 175890064 surfaceChanged -- format=4 w=1200 h=1920
I/SurfaceView@a7bde90(28766): surfaceChanged (1200,1920) 1 #1 io.flutter.embedding.android.FlutterSurfaceView{a7bde90 V.E...... ......ID 0,0-1200,1920}
I/SurfaceView(28766): 175890064 surfaceRedrawNeeded
V/SurfaceView(28766): Layout: x=0 y=0 w=1200 h=1920, frame=Rect(0, 0 - 1200, 1920)
D/VRI[MainActivity]@41e683e(28766): reportNextDraw android.view.ViewRootImpl.performTraversals:5193 android.view.ViewRootImpl.doTraversal:3708 android.view.ViewRootImpl$TraversalRunnable.run:12542 android.view.Choreographer$CallbackRecord.run:1751 android.view.Choreographer$CallbackRecord.run:1760
I/InsetsSourceConsumer(28766): applyRequestedVisibilityToControl: visible=true, type=statusBars, host=com.example.astrix_assist/com.example.astrix_assist.MainActivity
I/InsetsSourceConsumer(28766): applyRequestedVisibilityToControl: visible=true, type=navigationBars, host=com.example.astrix_assist/com.example.astrix_assist.MainActivity
I/SurfaceView(28766): 175890064 finishedDrawing
I/SurfaceView(28766): 175890064 finishedDrawing
D/VRI[MainActivity]@41e683e(28766): Setup new sync=wmsSync-VRI[MainActivity]@41e683e#2
I/VRI[MainActivity]@41e683e(28766): Creating new active sync group VRI[MainActivity]@41e683e#3
D/VRI[MainActivity]@41e683e(28766): Draw frame after cancel
D/VRI[MainActivity]@41e683e(28766): registerCallbacksForSync syncBuffer=false
D/SurfaceView(28766): 175890064 updateSurfacePosition RenderWorker, frameNr = 1, position = [0, 0, 1200, 1920] surfaceSize = 1200x1920
I/SurfaceView@a7bde90(28766): uSP: rtp = Rect(0, 0 - 1200, 1920) rtsw = 1200 rtsh = 1920
I/SurfaceView@a7bde90(28766): onSSPAndSRT: pl = 0 pt = 0 sx = 1.0 sy = 1.0
I/SurfaceView@a7bde90(28766): aOrMT: VRI[MainActivity]@41e683e t = android.view.SurfaceControl$Transaction@25a3b59 fN = 1 android.view.SurfaceView.-$$Nest$mapplyOrMergeTransaction:0 android.view.SurfaceView$SurfaceViewPositionUpdateListener.positionChanged:1792 android.graphics.RenderNode$CompositePositionUpdateListener.positionChanged:398
I/VRI[MainActivity]@41e683e(28766): mWNT: t=0xb400006eda83c500 mBlastBufferQueue=0xb400006edb619200 fn= 1 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SurfaceView.applyOrMergeTransaction:1723 android.view.SurfaceView.-$$Nest$mapplyOrMergeTransaction:0 android.view.SurfaceView$SurfaceViewPositionUpdateListener.positionChanged:1792
D/VRI[MainActivity]@41e683e(28766): Received frameDrawingCallback syncResult=0 frameNum=1.
I/VRI[MainActivity]@41e683e(28766): mWNT: t=0xb400006eda83ce00 mBlastBufferQueue=0xb400006edb619200 fn= 1 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.ViewRootImpl$11.onFrameDraw:15016 android.view.ThreadedRenderer$1.onFrameDraw:761 <bottom of call stack>
I/VRI[MainActivity]@41e683e(28766): Setting up sync and frameCommitCallback
I/VRI[MainActivity]@41e683e(28766): Received frameCommittedCallback lastAttemptedDrawFrameNum=1 didProduceBuffer=true
D/HWUI    (28766): CFMS:: SetUp Pid : 28766    Tid : 28798
D/VRI[MainActivity]@41e683e(28766): reportDrawFinished seqId=0
D/VRI[MainActivity]@41e683e(28766): mThreadedRenderer.initializeIfNeeded()#2 mSurface={isValid=true 0xb400006edb38a800}
D/InputMethodManagerUtils(28766): startInputInner - Id : 0
I/InputMethodManager(28766): startInputInner - IInputMethodManagerGlobalInvoker.startInputOrWindowGainedFocus
D/InputTransport(28766): Input channel constructed: 'ClientS', fd=179
I/InsetsSourceConsumer(28766): applyRequestedVisibilityToControl: visible=false, type=ime, host=com.example.astrix_assist/com.example.astrix_assist.MainActivity
I/VRI[MainActivity]@41e683e(28766): call setFrameRateCategory for touch hint category=high hint, reason=touch, vri=VRI[MainActivity]@41e683e
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   SshService.connect (package:astrix_assist/core/ssh_service.dart:117:17)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Connecting to SSH (attempt 1/3): root@192.168.85.88:22
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
W/WindowOnBackDispatcher(28766): OnBackInvokedCallback is not enabled for the application.
W/WindowOnBackDispatcher(28766): Set 'android:enableOnBackInvokedCallback="true"' in the application manifest.
W/WindowOnBackDispatcher(28766): OnBackInvokedCallback is not enabled for the application.
W/WindowOnBackDispatcher(28766): Set 'android:enableOnBackInvokedCallback="true"' in the application manifest.
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   SshService.connect (package:astrix_assist/core/ssh_service.dart:145:17)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 SSH connection established successfully on attempt 1
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AsteriskSshManager.connect (package:astrix_assist/core/services/asterisk_ssh_manager.dart:33:13)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 SSH connected to 192.168.85.88
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   SshService.connect (package:astrix_assist/core/ssh_service.dart:101:15)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 🐛 SSH already connected and healthy
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/VRI[MainActivity]@41e683e(28766): call setFrameRateCategory for touch hint category=no preference, reason=boost timeout, vri=VRI[MainActivity]@41e683e
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AsteriskSshManager._uploadScript (package:astrix_assist/core/services/asterisk_ssh_manager.dart:119:15)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Script uploaded to /usr/local/bin/astrix_collector.py
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AsteriskSshManager.ensureScriptDeployed (package:astrix_assist/core/services/asterisk_ssh_manager.dart:53:15)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Script deployed to /usr/local/bin/astrix_collector.py
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
W/WindowOnBackDispatcher(28766): OnBackInvokedCallback is not enabled for the application.
W/WindowOnBackDispatcher(28766): Set 'android:enableOnBackInvokedCallback="true"' in the application manifest.
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AmiDataSource.connect (package:astrix_assist/data/datasources/ami_datasource.dart:57:14)
I/flutter (28766): │ #1   ExtensionRepositoryImpl.getExtensions (package:astrix_assist/data/repositories/extension_repository_impl.dart:18:24)
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Connecting to AMI at 192.168.85.88:5038
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
W/WindowOnBackDispatcher(28766): OnBackInvokedCallback is not enabled for the application.
W/WindowOnBackDispatcher(28766): Set 'android:enableOnBackInvokedCallback="true"' in the application manifest.
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AmiDataSource.connect (package:astrix_assist/data/datasources/ami_datasource.dart:59:14)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Connected successfully
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AmiDataSource.login (package:astrix_assist/data/datasources/ami_datasource.dart:201:12)
I/flutter (28766): │ #1   ExtensionRepositoryImpl.getExtensions (package:astrix_assist/data/repositories/extension_repository_impl.dart:20:44)
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Sending login command
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AmiDataSource.getQueueStatus (package:astrix_assist/data/datasources/ami_datasource.dart:216:12)
I/flutter (28766): │ #1   ExtensionRepositoryImpl.getExtensions (package:astrix_assist/data/repositories/extension_repository_impl.dart:23:39)
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Sending SIPpeers command
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AmiDataSource.disconnect (package:astrix_assist/data/datasources/ami_datasource.dart:291:12)
I/flutter (28766): │ #1   ExtensionRepositoryImpl.getExtensions (package:astrix_assist/data/repositories/extension_repository_impl.dart:25:18)
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Disconnecting from AMI
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AmiDataSource.connect (package:astrix_assist/data/datasources/ami_datasource.dart:57:14)
I/flutter (28766): │ #1   MonitorRepositoryImpl.getActiveCalls (package:astrix_assist/data/repositories/monitor_repository_impl.dart:23:24)
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Connecting to AMI at 192.168.85.88:5038
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AmiDataSource.connect (package:astrix_assist/data/datasources/ami_datasource.dart:59:14)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Connected successfully
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AmiDataSource.login (package:astrix_assist/data/datasources/ami_datasource.dart:201:12)
I/flutter (28766): │ #1   MonitorRepositoryImpl.getActiveCalls (package:astrix_assist/data/repositories/monitor_repository_impl.dart:24:44)
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Sending login command
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AmiDataSource.getActiveCalls (package:astrix_assist/data/datasources/ami_datasource.dart:225:12)
I/flutter (28766): │ #1   MonitorRepositoryImpl.getActiveCalls (package:astrix_assist/data/repositories/monitor_repository_impl.dart:26:39)
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Sending CoreShowChannels command
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AmiDataSource.disconnect (package:astrix_assist/data/datasources/ami_datasource.dart:291:12)
I/flutter (28766): │ #1   MonitorRepositoryImpl.getActiveCalls (package:astrix_assist/data/repositories/monitor_repository_impl.dart:27:18)
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Disconnecting from AMI
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   MonitorRepositoryImpl.getActiveCalls (package:astrix_assist/data/repositories/monitor_repository_impl.dart:74:15)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 📞 getActiveCalls: Received 1 channels, filtered to 0 calls
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AmiDataSource.connect (package:astrix_assist/data/datasources/ami_datasource.dart:49:14)
I/flutter (28766): │ #1   MonitorRepositoryImpl.getQueueStatuses (package:astrix_assist/data/repositories/monitor_repository_impl.dart:89:24)
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ ! Socket already exists, disconnecting first...
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AmiDataSource.disconnect (package:astrix_assist/data/datasources/ami_datasource.dart:291:12)
I/flutter (28766): │ #1   AmiDataSource.connect (package:astrix_assist/data/datasources/ami_datasource.dart:50:7)
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Disconnecting from AMI
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AmiDataSource.connect (package:astrix_assist/data/datasources/ami_datasource.dart:57:14)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Connecting to AMI at 192.168.85.88:5038
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AmiDataSource.connect (package:astrix_assist/data/datasources/ami_datasource.dart:59:14)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Connected successfully
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AmiDataSource.login (package:astrix_assist/data/datasources/ami_datasource.dart:201:12)
I/flutter (28766): │ #1   MonitorRepositoryImpl.getQueueStatuses (package:astrix_assist/data/repositories/monitor_repository_impl.dart:90:44)
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Sending login command
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AmiDataSource.getQueueStatuses (package:astrix_assist/data/datasources/ami_datasource.dart:234:12)
I/flutter (28766): │ #1   MonitorRepositoryImpl.getQueueStatuses (package:astrix_assist/data/repositories/monitor_repository_impl.dart:92:39)
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Sending QueueStatus command
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AmiDataSource.disconnect (package:astrix_assist/data/datasources/ami_datasource.dart:291:12)
I/flutter (28766): │ #1   MonitorRepositoryImpl.getQueueStatuses (package:astrix_assist/data/repositories/monitor_repository_impl.dart:93:18)
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Disconnecting from AMI
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AmiDataSource.connect (package:astrix_assist/data/datasources/ami_datasource.dart:49:14)
I/flutter (28766): │ #1   MonitorRepositoryImpl.getActiveCalls (package:astrix_assist/data/repositories/monitor_repository_impl.dart:23:24)
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ ! Socket already exists, disconnecting first...
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AmiDataSource.disconnect (package:astrix_assist/data/datasources/ami_datasource.dart:291:12)
I/flutter (28766): │ #1   AmiDataSource.connect (package:astrix_assist/data/datasources/ami_datasource.dart:50:7)
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Disconnecting from AMI
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AmiDataSource.connect (package:astrix_assist/data/datasources/ami_datasource.dart:57:14)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Connecting to AMI at 192.168.85.88:5038
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AmiDataSource.connect (package:astrix_assist/data/datasources/ami_datasource.dart:59:14)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Connected successfully
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AmiDataSource.login (package:astrix_assist/data/datasources/ami_datasource.dart:201:12)
I/flutter (28766): │ #1   MonitorRepositoryImpl.getActiveCalls (package:astrix_assist/data/repositories/monitor_repository_impl.dart:24:44)
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Sending login command
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AmiDataSource.getActiveCalls (package:astrix_assist/data/datasources/ami_datasource.dart:225:12)
I/flutter (28766): │ #1   MonitorRepositoryImpl.getActiveCalls (package:astrix_assist/data/repositories/monitor_repository_impl.dart:26:39)
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Sending CoreShowChannels command
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AmiDataSource.disconnect (package:astrix_assist/data/datasources/ami_datasource.dart:291:12)
I/flutter (28766): │ #1   MonitorRepositoryImpl.getActiveCalls (package:astrix_assist/data/repositories/monitor_repository_impl.dart:27:18)
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Disconnecting from AMI
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   MonitorRepositoryImpl.getActiveCalls (package:astrix_assist/data/repositories/monitor_repository_impl.dart:74:15)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 📞 getActiveCalls: Received 1 channels, filtered to 0 calls
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/VRI[MainActivity]@41e683e(28766): call setFrameRateCategory for touch hint category=high hint, reason=touch, vri=VRI[MainActivity]@41e683e
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   new CdrBloc.<anonymous closure> (package:astrix_assist/presentation/blocs/cdr_bloc.dart:21:14)
I/flutter (28766): │ #1   Bloc.on.<anonymous closure>.handleEvent (package:bloc/src/bloc.dart:226:26)
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 📞 LoadCdrRecords event received with: startDate=2025-12-16 16:23:40.310280, endDate=2025-12-23 16:23:40.310280, src=null, dst=null, disposition=null, limit=100
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   new CdrBloc.<anonymous closure> (package:astrix_assist/presentation/blocs/cdr_bloc.dart:23:14)
I/flutter (28766): │ #1   Bloc.on.<anonymous closure>.handleEvent (package:bloc/src/bloc.dart:226:26)
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 🐛 ⏳ CdrLoading state emitted, calling use case...
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   SshCdrDataSource.getCdrRecords (package:astrix_assist/data/datasources/ssh_cdr_datasource.dart:23:15)
I/flutter (28766): │ #1   CdrRepositoryImpl.getCdrRecords (package:astrix_assist/data/repositories/cdr_repository_impl.dart:21:40)
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 📞 getCdrRecords called with: startDate=2025-12-16 16:23:40.310280, endDate=2025-12-23 16:23:40.310280, src=null, dst=null, disposition=null, limit=100
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   SshCdrDataSource.getCdrRecords (package:astrix_assist/data/datasources/ssh_cdr_datasource.dart:27:15)
I/flutter (28766): │ #1   CdrRepositoryImpl.getCdrRecords (package:astrix_assist/data/repositories/cdr_repository_impl.dart:21:40)
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 🐛 📅 Calculated days: 8
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   SshCdrDataSource.getCdrRecords (package:astrix_assist/data/datasources/ssh_cdr_datasource.dart:30:15)
I/flutter (28766): │ #1   CdrRepositoryImpl.getCdrRecords (package:astrix_assist/data/repositories/cdr_repository_impl.dart:21:40)
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 🐛 🔍 Calling sshManager.getCdrs with days=8, limit=100
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AsteriskSshManager.getCdrs (package:astrix_assist/core/services/asterisk_ssh_manager.dart:199:15)
I/flutter (28766): │ #1   SshCdrDataSource.getCdrRecords (package:astrix_assist/data/datasources/ssh_cdr_datasource.dart:31:41)
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 📞 getCdrs called with days=8, limit=100
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AsteriskSshManager.getCdrs (package:astrix_assist/core/services/asterisk_ssh_manager.dart:201:15)
I/flutter (28766): │ #1   SshCdrDataSource.getCdrRecords (package:astrix_assist/data/datasources/ssh_cdr_datasource.dart:31:41)
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 🐛 🔧 Executing command: cdr --days 8 --limit 100
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   SshService._executeWithRecovery (package:astrix_assist/core/ssh_service.dart:70:15)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Connection unhealthy, attempting reconnect
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   SshService.disconnect (package:astrix_assist/core/ssh_service.dart:184:15)
I/flutter (28766): │ #1   SshService._executeWithRecovery (package:astrix_assist/core/ssh_service.dart:71:13)
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 SSH disconnected
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   SshService.connect (package:astrix_assist/core/ssh_service.dart:117:17)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Connecting to SSH (attempt 1/3): root@192.168.85.88:22
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
W/WindowOnBackDispatcher(28766): OnBackInvokedCallback is not enabled for the application.
W/WindowOnBackDispatcher(28766): Set 'android:enableOnBackInvokedCallback="true"' in the application manifest.
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   SshService.connect (package:astrix_assist/core/ssh_service.dart:145:17)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 SSH connection established successfully on attempt 1
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   SshService.connect (package:astrix_assist/core/ssh_service.dart:101:15)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 🐛 SSH already connected and healthy
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AsteriskSshManager._uploadScript (package:astrix_assist/core/services/asterisk_ssh_manager.dart:119:15)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Script uploaded to /usr/local/bin/astrix_collector.py
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AsteriskSshManager.ensureScriptDeployed (package:astrix_assist/core/services/asterisk_ssh_manager.dart:53:15)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 Script deployed to /usr/local/bin/astrix_collector.py
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/VRI[MainActivity]@41e683e(28766): call setFrameRateCategory for touch hint category=no preference, reason=boost timeout, vri=VRI[MainActivity]@41e683e
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AsteriskSshManager.getCdrs (package:astrix_assist/core/services/asterisk_ssh_manager.dart:204:15)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 🐛 📤 Script output length: 59014 chars
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AsteriskSshManager.getCdrs (package:astrix_assist/core/services/asterisk_ssh_manager.dart:211:15)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 🐛 📦 Decoded JSON keys: success, count, records, debug_info, timestamp
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AsteriskSshManager.getCdrs (package:astrix_assist/core/services/asterisk_ssh_manager.dart:215:17)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 🐛 🔍 Debug Info: {cdr_file: /var/log/asterisk/cdr-csv/Master.csv, total_lines: 754, records_returned: 100, limit: 100, note: Date filtering disabled - client handles timezone-aware filtering}
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AsteriskSshManager.getCdrs (package:astrix_assist/core/services/asterisk_ssh_manager.dart:230:17)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 ✅ getCdrs returning 100 records
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   AsteriskSshManager.getCdrs (package:astrix_assist/core/services/asterisk_ssh_manager.dart:232:19)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 🐛 📋 First record: {accountcode: , src: 5191001376, dst: 09155119004, dcontext: from-internal, clid:  <5191001376>, channel: SIP/1003-000000c6, dstchannel: SIP/shatel-trunk-000000c7, lastapp: Dial, lastdata: SIP/shatel-trunk/09155119004,300,T, calldate: 2025-12-23 12:41:27, answerdate: 2025-12-23 12:41:33, enddate: 2025-12-23 12:41:56, duration: 29, billsec: 23, disposition: ANSWERED, amaflags: DOCUMENTATION, uniqueid: 1766493687.1420, userfield: }      
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   SshCdrDataSource.getCdrRecords (package:astrix_assist/data/datasources/ssh_cdr_datasource.dart:36:15)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 🐛 📥 Response received: success=true, error=null
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   SshCdrDataSource.getCdrRecords (package:astrix_assist/data/datasources/ssh_cdr_datasource.dart:44:15)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 🐛 📋 Raw records count: 100
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   SshCdrDataSource.getCdrRecords (package:astrix_assist/data/datasources/ssh_cdr_datasource.dart:49:17)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 🐛 📄 First record sample: {accountcode: , src: 5191001376, dst: 09155119004, dcontext: from-internal, clid:  <5191001376>, channel: SIP/1003-000000c6, dstchannel: SIP/shatel-trunk-000000c7, lastapp: Dial, lastdata: SIP/shatel-trunk/09155119004,300,T, calldate: 2025-12-23 12:41:27, answerdate: 2025-12-23 12:41:33, enddate: 2025-12-23 12:41:56, duration: 29, billsec: 23, disposition: ANSWERED, amaflags: DOCUMENTATION, uniqueid: 1766493687.1420, userfield: }
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   SshCdrDataSource.getCdrRecords (package:astrix_assist/data/datasources/ssh_cdr_datasource.dart:53:15)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 🐛 ✅ Parsed 100 records
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   SshCdrDataSource.getCdrRecords (package:astrix_assist/data/datasources/ssh_cdr_datasource.dart:66:15)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 ✅ After filtering: 100 CDR records (from 100 raw)
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   new CdrBloc.<anonymous closure> (package:astrix_assist/presentation/blocs/cdr_bloc.dart:34:14)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 🐛 📦 Use case returned result: Success<List<CdrRecord>>
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   new CdrBloc.<anonymous closure> (package:astrix_assist/presentation/blocs/cdr_bloc.dart:38:18)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 💡 ✅ Loaded 100 CDR records
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   new CdrBloc.<anonymous closure> (package:astrix_assist/presentation/blocs/cdr_bloc.dart:42:20)
I/flutter (28766): │ #1   <asynchronous suspension>
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 🐛 📋 First CDR: 2025-12-23 12:41:27 5191001376 -> 09155119004
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/VRI[MainActivity]@41e683e(28766): call setFrameRateCategory for touch hint category=high hint, reason=touch, vri=VRI[MainActivity]@41e683e
W/WindowOnBackDispatcher(28766): OnBackInvokedCallback is not enabled for the application.
W/WindowOnBackDispatcher(28766): Set 'android:enableOnBackInvokedCallback="true"' in the application manifest.
I/flutter (28766): ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): │ #0   SshService.listRecordings.<anonymous closure> (package:astrix_assist/core/ssh_service.dart:216:15)
I/flutter (28766): │ #1   SshService._executeWithRecovery (package:astrix_assist/core/ssh_service.dart:76:29)
I/flutter (28766): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (28766): │ 🐛 Listing recordings in: /var/spool/asterisk/monitor/2025/12/23 12:41:27
I/flutter (28766): └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
I/flutter (28766): Play button error: SftpStatusError: No such file(code 2)
E/flutter (28766): [ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: 'package:go_router/src/delegate.dart': Failed assertion: line 175 pos 7: 'currentConfiguration.isNotEmpty': You have popped the last page off of the stack, there are no pages left to show
E/flutter (28766): #0      _AssertionError._doThrowNew (dart:core-patch/errors_patch.dart:67:4)
E/flutter (28766): #1      _AssertionError._throwNew (dart:core-patch/errors_patch.dart:49:5)
E/flutter (28766): #2      GoRouterDelegate._debugAssertMatchListNotEmpty (package:go_router/src/delegate.dart:175:7)
E/flutter (28766): #3      GoRouterDelegate._completeRouteMatch (package:go_router/src/delegate.dart:196:5)
E/flutter (28766): #4      GoRouterDelegate._handlePopPageWithRouteMatch (package:go_router/src/delegate.dart:154:7)
E/flutter (28766): #5      _CustomNavigatorState._handlePopPage (package:go_router/src/builder.dart:446:42)
E/flutter (28766): #6      NavigatorState.pop (package:flutter/src/widgets/navigator.dart:5581:28)
E/flutter (28766): #7      _CdrPageState._buildBody.<anonymous closure>.<anonymous closure>.<anonymous closure> (package:astrix_assist/presentation/pages/cdr_page.dart:246:45)
E/flutter (28766): <asynchronous suspension>
E/flutter (28766):

══╡ EXCEPTION CAUGHT BY WIDGETS LIBRARY ╞═══════════════════════════════════════════════════════════
The following assertion was thrown while finalizing the widget tree:
'package:flutter/src/widgets/navigator.dart': Failed assertion: line 4064 pos 12: '!_debugLocked':
is not true.

Either the assertion indicates an error in the framework itself, or we should provide substantially
more information in this error message to help you determine and fix the underlying cause.
In either case, please report this assertion by filing a bug on GitHub:
  https://github.com/flutter/flutter/issues/new?template=02_bug.yml

When the exception was thrown, this was the stack:
#2      NavigatorState.dispose (package:flutter/src/widgets/navigator.dart:4064:12)
#3      StatefulElement.unmount (package:flutter/src/widgets/framework.dart:6033:11)
#4      _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2117:13)
#5      _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#6      ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#7      _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#8      _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#9      ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#10     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#11     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#12     ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#13     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#14     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#15     ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#16     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#17     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#18     ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#19     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#20     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#21     MultiChildRenderObjectElement.visitChildren (package:flutter/src/widgets/framework.dart:7228:16)
#22     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#23     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#24     ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#25     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#26     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#27     ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#28     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#29     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#30     ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#31     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#32     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#33     ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#34     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#35     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#36     MultiChildRenderObjectElement.visitChildren (package:flutter/src/widgets/framework.dart:7228:16)
#37     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#38     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#39     ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#40     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#41     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#42     ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#43     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#44     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#45     ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#46     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#47     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#48     ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#49     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#50     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#51     ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#52     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#53     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#54     SingleChildRenderObjectElement.visitChildren (package:flutter/src/widgets/framework.dart:7104:14)
#55     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#56     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#57     ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#58     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#59     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#60     SingleChildRenderObjectElement.visitChildren (package:flutter/src/widgets/framework.dart:7104:14)
#61     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#62     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#63     ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#64     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#65     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#66     ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#67     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#68     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#69     ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#70     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#71     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#72     ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#73     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#74     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#75     ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#76     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#77     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#78     ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#79     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#80     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#81     ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#82     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#83     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#84     ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#85     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#86     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#87     ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#88     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#89     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#90     ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#91     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#92     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#93     SingleChildRenderObjectElement.visitChildren (package:flutter/src/widgets/framework.dart:7104:14)
#94     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#95     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#96     ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#97     _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#98     _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#99     SingleChildRenderObjectElement.visitChildren (package:flutter/src/widgets/framework.dart:7104:14)
#100    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#101    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#102    SingleChildRenderObjectElement.visitChildren (package:flutter/src/widgets/framework.dart:7104:14)
#103    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#104    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#105    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#106    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#107    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#108    SingleChildRenderObjectElement.visitChildren (package:flutter/src/widgets/framework.dart:7104:14)
#109    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#110    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#111    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#112    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#113    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#114    SingleChildRenderObjectElement.visitChildren (package:flutter/src/widgets/framework.dart:7104:14)
#115    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#116    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#117    SingleChildRenderObjectElement.visitChildren (package:flutter/src/widgets/framework.dart:7104:14)
#118    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#119    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#120    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#121    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#122    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#123    SingleChildRenderObjectElement.visitChildren (package:flutter/src/widgets/framework.dart:7104:14)
#124    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#125    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#126    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#127    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#128    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#129    SingleChildRenderObjectElement.visitChildren (package:flutter/src/widgets/framework.dart:7104:14)
#130    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#131    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#132    SingleChildRenderObjectElement.visitChildren (package:flutter/src/widgets/framework.dart:7104:14)
#133    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#134    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#135    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#136    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#137    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#138    SingleChildRenderObjectElement.visitChildren (package:flutter/src/widgets/framework.dart:7104:14)
#139    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#140    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#141    SingleChildRenderObjectElement.visitChildren (package:flutter/src/widgets/framework.dart:7104:14)
#142    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#143    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#144    SingleChildRenderObjectElement.visitChildren (package:flutter/src/widgets/framework.dart:7104:14)
#145    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#146    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#147    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#148    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#149    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#150    SingleChildRenderObjectElement.visitChildren (package:flutter/src/widgets/framework.dart:7104:14)
#151    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#152    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#153    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#154    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#155    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#156    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#157    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#158    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#159    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#160    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#161    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#162    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#163    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#164    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#165    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#166    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#167    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#168    SingleChildRenderObjectElement.visitChildren (package:flutter/src/widgets/framework.dart:7104:14)
#169    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#170    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#171    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#172    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#173    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#174    SingleChildRenderObjectElement.visitChildren (package:flutter/src/widgets/framework.dart:7104:14)
#175    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#176    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#177    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#178    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#179    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#180    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#181    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#182    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#183    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#184    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#185    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#186    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#187    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#188    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#189    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#190    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#191    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#192    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#193    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#194    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#195    SingleChildRenderObjectElement.visitChildren (package:flutter/src/widgets/framework.dart:7104:14)
#196    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#197    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#198    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#199    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#200    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#201    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#202    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#203    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#204    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#205    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#206    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#207    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#208    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#209    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#210    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#211    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#212    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#213    SingleChildRenderObjectElement.visitChildren (package:flutter/src/widgets/framework.dart:7104:14)
#214    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#215    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#216    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#217    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#218    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#219    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#220    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#221    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#222    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#223    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#224    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#225    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#226    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#227    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#228    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#229    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#230    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#231    MultiChildRenderObjectElement.visitChildren (package:flutter/src/widgets/framework.dart:7228:16)
#232    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#233    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#234    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#235    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#236    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#237    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#238    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#239    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#240    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#241    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#242    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#243    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#244    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#245    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#246    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#247    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#248    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#249    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#250    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#251    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#252    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#253    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#254    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#255    SingleChildRenderObjectElement.visitChildren (package:flutter/src/widgets/framework.dart:7104:14)
#256    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#257    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#258    SingleChildRenderObjectElement.visitChildren (package:flutter/src/widgets/framework.dart:7104:14)
#259    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#260    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#261    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#262    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#263    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#264    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#265    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#266    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#267    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#268    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#269    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#270    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#271    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#272    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#273    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#274    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#275    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#276    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#277    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#278    _InactiveElements._unmount.<anonymous closure> (package:flutter/src/widgets/framework.dart:2115:7)
#279    ComponentElement.visitChildren (package:flutter/src/widgets/framework.dart:5874:14)
#280    _InactiveElements._unmount (package:flutter/src/widgets/framework.dart:2113:13)
#281    ListIterable.forEach (dart:_internal/iterable.dart:49:13)
#282    _InactiveElements._unmountAll (package:flutter/src/widgets/framework.dart:2126:25)
#283    BuildOwner.lockState (package:flutter/src/widgets/framework.dart:3020:15)
#284    BuildOwner.finalizeTree (package:flutter/src/widgets/framework.dart:3344:7)
#285    WidgetsBinding.drawFrame (package:flutter/src/widgets/binding.dart:1269:19)
#286    RendererBinding._handlePersistentFrameCallback (package:flutter/src/rendering/binding.dart:495:5)
#287    SchedulerBinding._invokeFrameCallback (package:flutter/src/scheduler/binding.dart:1434:15)
#288    SchedulerBinding.handleDrawFrame (package:flutter/src/scheduler/binding.dart:1347:9)
#289    SchedulerBinding._handleDrawFrame (package:flutter/src/scheduler/binding.dart:1200:5)
#290    _invoke (dart:ui/hooks.dart:356:13)
#291    PlatformDispatcher._drawFrame (dart:ui/platform_dispatcher.dart:444:5)
#292    _drawFrame (dart:ui/hooks.dart:328:31)
(elided 2 frames from class _AssertionError)
════════════════════════════════════════════════════════════════════════════════════════════════════

I/VRI[MainActivity]@41e683e(28766): call setFrameRateCategory for touch hint category=no preference, reason=boost timeout, vri=VRI[MainActivity]@41e683e
