package com.tube_download_master;
import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class DemoApplication extends FlutterApplication implements PluginRegistry.PluginRegistrantCallback {
    @Override
    public void registerWith(PluginRegistry registry) {
        GeneratedPluginRegistrant.registerWith(registry);
//        FlutterDownloaderPlugin.registerWith(registry.registrarFor("vn.hunghd.flutterdownloader.FlutterDownloaderPlugin"));
    }
}