/*
       Licensed to the Apache Software Foundation (ASF) under one
       or more contributor license agreements.  See the NOTICE file
       distributed with this work for additional information
       regarding copyright ownership.  The ASF licenses this file
       to you under the Apache License, Version 2.0 (the
       "License"); you may not use this file except in compliance
       with the License.  You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing,
       software distributed under the License is distributed on an
       "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
       KIND, either express or implied.  See the License for the
       specific language governing permissions and limitations
       under the License.
 */

/*
       Licensed to the Apache Software Foundation (ASF) under one
       or more contributor license agreements.  See the NOTICE file
       distributed with this work for additional information
       regarding copyright ownership.  The ASF licenses this file
       to you under the Apache License, Version 2.0 (the
       "License"); you may not use this file except in compliance
       with the License.  You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing,
       software distributed under the License is distributed on an
       "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
       KIND, either express or implied.  See the License for the
       specific language governing permissions and limitations
       under the License.
 */

package com.citymobi.fufu;

import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;

import com.umeng.analytics.MobclickAgent;

import org.apache.cordova.CordovaActivity;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Enumeration;
import java.util.zip.ZipEntry;
import java.util.zip.ZipException;
import java.util.zip.ZipFile;

import cn.jpush.android.api.JPushInterface;

public class MainActivity extends CordovaActivity {

    //当前版本
    private String currentVersion = "";
    //上一版本
    private String lastVersion = null;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        loadUrl(launchUrl);
//        AndroidBug5497Workaround.assistActivity(this);

        try {
            PackageManager packageManager = getPackageManager();
            // getPackageName()是你当前类的包名，0代表是获取版本信息
            PackageInfo packInfo = packageManager.getPackageInfo(getPackageName(), 0);
            currentVersion = packInfo.versionName;
        } catch (Exception e) {
            e.printStackTrace();
        }

        SharedPreferences settings = getSharedPreferences("setting", MODE_APPEND);

        final SharedPreferences.Editor editor = settings.edit();//获取编辑器

        lastVersion = settings.getString("VERSION", null);

//        Toast.makeText(this, currentVersion + "---" + lastVersion, Toast.LENGTH_LONG).show();

        if (!currentVersion.equals(lastVersion) || lastVersion == null) {  //没有保存数据
            new Thread(new Runnable() {
                @Override
                public void run() {
                    fileCheck();
                    copyFile(0, editor);
                }
            }).start();
        }

    }

    @Override
    protected void onResume() {
        super.onResume();
        JPushInterface.onResume(this);
        MobclickAgent.onResume(this);
    }

    @Override
    protected void onPause() {
        super.onPause();
        JPushInterface.onPause(this);
        MobclickAgent.onPause(this);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    //判断www.zip是否存在
    private void fileCheck() {
        File exitFile = new File("/data/data/com.citymobi.fufu/files/www.zip");

        if (exitFile.exists()) {
            exitFile.delete();
        }
    }

    private void copyFile(int a, SharedPreferences.Editor editor) {

        try {
            if (a != 2) {
                InputStream inputStream = getAssets().open("www.zip");
                FileOutputStream fos = new FileOutputStream(new File("/data/data/com.citymobi.fufu/files/www.zip"));
                byte[] buffer = new byte[1024];
                int byteCount = 0;
                while ((byteCount = inputStream.read(buffer)) != -1) {//循环从输入流读取 buffer字节
                    fos.write(buffer, 0, byteCount);//将读取的输入流写入到输出流
                }
                fos.flush();//刷新缓冲区
                inputStream.close();
                fos.close();
            }

            try {
                upZipFile(new File("/data/data/com.citymobi.fufu/files/www.zip"), "/data/data/com.citymobi.fufu/files/");
            } catch (Exception e) {
                e.printStackTrace();
                copyFile(2, editor);
            }

            //存入数据
            editor.putString("VERSION", currentVersion);

            editor.putBoolean("isCopy", true);

            editor.commit();

        } catch (Exception e) {
            e.printStackTrace();

            editor.putString("VERSION", lastVersion);

            editor.putBoolean("isCopy", false);

            editor.commit();

            fileCheck();
            if (a == 0) {
                copyFile(1, editor);
            }
        }

    }

    //解压文件
    public static void upZipFile(File zipFile, String folderPath) throws ZipException, IOException {

        File desDir = new File(folderPath);
        if (!desDir.exists()) {
            desDir.mkdirs();
        }

        ZipFile zf = new ZipFile(zipFile);
        for (Enumeration<?> entries = zf.entries(); entries.hasMoreElements(); ) {
            ZipEntry entry = ((ZipEntry) entries.nextElement());
            if (entry.isDirectory()) {
                continue;
            }

            InputStream in = zf.getInputStream(entry);
            String str = folderPath + File.separator + entry.getName();
            str = new String(str.getBytes(), "utf-8");
            File desFile = new File(str);
            if (!desFile.exists()) {
                File fileParentDir = desFile.getParentFile();
                if (!fileParentDir.exists()) {
                    fileParentDir.mkdirs();
                }
                desFile.createNewFile();
            }
            OutputStream out = new FileOutputStream(desFile);
            byte buffer[] = new byte[1024];
            int realLength;
            while ((realLength = in.read(buffer)) > 0) {
                out.write(buffer, 0, realLength);
            }
            in.close();
            out.close();
        }
    }


    private void setStyleCustom() {

//        CustomPushNotificationBuilder builder=new CustomPushNotificationBuilder(this, R.layout.test_notification_layout,
//                R.id.icon, R.id.title, R.id.text);
////        builder.statusBarDrawable=R.drawable.bb;
////        builder.layoutIconDrawable=R.drawable.aa;
//        builder.notificationDefaults= Notification.DEFAULT_SOUND;
//        builder.notificationFlags=Notification.FLAG_AUTO_CANCEL;
//        builder.developerArg0="gly";
//        JPushInterface.setPushNotificationBuilder(1, builder);

//        RemoteViews remoteViews = new RemoteViews(this.getPackageName(), R.layout.test_notification_layout);
//        remoteViews.setTextViewText(R.id.title, "titletielteeeeeeeeeeee");
//        remoteViews.setTextViewText(R.id.text, "content ocnetetete================");
////        remoteViews.setTextViewText(R.id.time_tv, getTime());
//        remoteViews.setImageViewResource(R.id.icon, R.drawable.icon);
//
//        Intent intent = new Intent(this, ShowAllImageActivity.class);
//        intent.putExtra(NOTICE_ID_KEY, NOTICE_ID_TYPE_0);
//        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
//        int requestCode = (int) SystemClock.uptimeMillis();
//        PendingIntent pendingIntent = PendingIntent.getActivity(this, requestCode, intent, PendingIntent.FLAG_UPDATE_CURRENT);
////        remoteViews.setOnClickPendingIntent(R.id.notice_view_type_0, pendingIntent);
//        int requestCode1 = (int) SystemClock.uptimeMillis();
//        Intent intent1 = new Intent(ACTION_CLOSE_NOTICE);
//        intent1.putExtra(NOTICE_ID_KEY, NOTICE_ID_TYPE_0);
//        PendingIntent pendingIntent1 = PendingIntent.getBroadcast(this, requestCode1, intent1, PendingIntent.FLAG_UPDATE_CURRENT);
////        remoteViews.setOnClickPendingIntent(R.id.close_iv, pendingIntent1);
//
//        NotificationCompat.Builder builder = new NotificationCompat.Builder(this);
//        builder.setOngoing(true);
//        builder.setPriority(NotificationCompat.PRIORITY_MAX);
//
//        Notification notification = builder.build();
//
//
////        if(android.os.Build.VERSION.SDK_INT >= 16) {
//            notification = builder.build();
//            notification.bigContentView = remoteViews;
////        }
////
//        notification.contentView = remoteViews;
//        NotificationManager manager = (NotificationManager) this.getSystemService(Context.NOTIFICATION_SERVICE);
//        manager.notify(NOTICE_ID_TYPE_0, notification);


    }


}
