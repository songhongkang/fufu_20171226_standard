package org.apache.cordova.camera;

import android.app.ActionBar;
import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.citymobi.fufu.R;
import com.oginotihiro.cropview.CropUtil;
import com.oginotihiro.cropview.CropView;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;

public class CropViewActivity extends Activity {

    private static final String SAVE_PIC_PATH=Environment.getExternalStorageState().equalsIgnoreCase(Environment.MEDIA_MOUNTED) ? Environment.getExternalStorageDirectory().getAbsolutePath() : "/mnt/sdcard" ;//保存到SD卡
    private static final String SAVE_REAL_PATH = SAVE_PIC_PATH+ "/good/savePic";//保存的确切位置

    private CropView cropView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_crop_view);

        ActionBar bar = getActionBar();
        bar.hide();

        TextView textTitle = (TextView) findViewById(R.id.title);
        textTitle.setText("截图");

        Uri uri = Uri.parse(getIntent().getStringExtra("uri"));
        int x = getIntent().getIntExtra("aspectX",1);
        int y = getIntent().getIntExtra("aspectY",1);
        int width = getIntent().getIntExtra("outputX",400);
        int height = getIntent().getIntExtra("outputY",400);
        cropView = (CropView) findViewById(R.id.cropView);
        cropView.of(uri)
                .withAspect(x,y)
                .withOutputSize(width, height)
                .initialize(CropViewActivity.this);

        final TextView crop = (TextView) findViewById(R.id.right_text);
        crop.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Bitmap croppedBitmap = cropView.getOutput();

                SimpleDateFormat formatter    =   new SimpleDateFormat("yyyyMMddHHmmss");
                Date    curDate    =   new    Date(System.currentTimeMillis());//获取当前时间
                String    str    =    formatter.format(curDate);

                File imageFile = new File(getCacheDir(), str+".png");

                if (imageFile.exists()) {
                    imageFile.delete();
                }

                Uri destination = Uri.fromFile(new File(getCacheDir(), str+".png"));

                CropUtil.saveOutput(CropViewActivity.this, destination, croppedBitmap, 80);

                Intent backData = new Intent();
                backData.putExtra("uri",destination.toString());
                setResult(10500,backData);

                finish();

            }
        });

        ImageView back = (ImageView) findViewById(R.id.left_btn);
        back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                backImage();
            }
        });
    }

    @Override
    public void onBackPressed() {
        backImage();
        super.onBackPressed();
    }

    private void backImage() {
        Intent backData = new Intent();
        backData.putExtra("uri","");
        setResult(10500,backData);
        finish();
    }
}
