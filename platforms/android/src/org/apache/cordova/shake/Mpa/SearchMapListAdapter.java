package org.apache.cordova.shake.Mpa;

import android.content.Context;
import android.content.res.Resources;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.citymobi.fufu.R;

import java.util.LinkedList;
import java.util.List;

/**
 * Created by shangzh on 16/6/27.
 */
public class SearchMapListAdapter extends BaseAdapter {

    private List<SearchAddress> mData;
    private Context mContext;
    private Resources resources;

    public SearchMapListAdapter(LinkedList<SearchAddress> mData, Context mContext, Resources resources) {
        this.mData = mData;
        this.mContext = mContext;
        this.resources = resources;
    }

    @Override
    public int getCount() {
        return mData.size();
    }

    @Override
    public Object getItem(int i) {
        return null;
    }

    @Override
    public long getItemId(int i) {
        return i;
    }


    @Override
    public View getView(int i, View convertView, ViewGroup viewGroup) {
        ViewHolder holder = null;

        if(convertView == null){
            convertView = LayoutInflater.from(mContext).inflate(R.layout.search_map_item_list,viewGroup,false);
            holder = new ViewHolder();
            holder.txt_title = (TextView) convertView.findViewById(R.id.txt_title);
            holder.txt_content = (TextView) convertView.findViewById(R.id.txt_content);
            holder.imgView = (ImageView) convertView.findViewById(R.id.selectimage);
            convertView.setTag(holder);
        }else{
            holder = (ViewHolder) convertView.getTag();
        }
        holder.txt_title.setText(mData.get(i).getAddressTitle());
        holder.txt_content.setText(mData.get(i).getDescrip());
        holder.imgView.setImageResource(R.drawable.search_address);

        return convertView;
    }

    private class ViewHolder{
        TextView txt_title;
        TextView txt_content;
        ImageView imgView;
    }
}
