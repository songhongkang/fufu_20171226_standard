package com.citymobi.fufu.utils;

import android.content.Intent;
import android.net.Uri;
import android.provider.Settings;
import android.support.annotation.NonNull;
import android.support.annotation.StringRes;
import android.view.View;

import com.citymobi.fufu.application.FuFuApplication;
import com.citymobi.fufu.widgets.CustomDialog;

import org.apache.cordova.CordovaPlugin;

/**
 * 权限管理
 * Created by ZhongQuan on 2017/2/21.
 */

public class PermissionManage {

    /**
     * 打开权限提示框，进入应用详细设置
     *
     * @param cordovaPlugin
     * @param title
     * @param message
     */
    public static void openPermissionHint(final CordovaPlugin cordovaPlugin, String title, String message) {
        final CustomDialog mDialog = CustomDialog.getCustomDialog(cordovaPlugin.cordova.getActivity());
        mDialog.setInfo(title, message);
        mDialog.setListenerYes(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent localIntent = new Intent();
                localIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                localIntent.setAction("android.settings.APPLICATION_DETAILS_SETTINGS");
                localIntent.setData(Uri.fromParts("package", "com.citymobi.fufu", null));
                cordovaPlugin.cordova.startActivityForResult(cordovaPlugin, localIntent, 0);
                mDialog.hideDialog();
            }
        });
        mDialog.showDialog();
    }


    public static void openPermissionHint(@NonNull CordovaPlugin cordovaPlugin, @StringRes int titleRes, @StringRes int msgRes) {
        openPermissionHint(cordovaPlugin, FuFuApplication.getmInstance().getString(titleRes), FuFuApplication.getmInstance().getString(msgRes));
    }

    /**
     * 打开提示框，进入app设置
     *
     * @param cordovaPlugin
     * @param title
     * @param message
     */
    public static void openAppSettingHint(final CordovaPlugin cordovaPlugin, String title, String message) {
        final CustomDialog mDialog = CustomDialog.getCustomDialog(cordovaPlugin.cordova.getActivity());
        mDialog.setInfo(title, message);
        mDialog.setListenerYes(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent localIntent = new Intent(Settings.ACTION_SETTINGS);
                cordovaPlugin.cordova.startActivityForResult(cordovaPlugin, localIntent, 0);
                mDialog.hideDialog();
            }
        });
        mDialog.showDialog();
    }

    public static void openAppSettingHint(@NonNull CordovaPlugin cordovaPlugin, @StringRes int titleRes, @StringRes int msgRes) {
        openAppSettingHint(cordovaPlugin, FuFuApplication.getmInstance().getString(titleRes), FuFuApplication.getmInstance().getString(msgRes));
    }
}
