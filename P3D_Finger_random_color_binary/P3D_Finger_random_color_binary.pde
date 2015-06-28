//P3Dによる指のグラフィックス(配列で複数指ver)
//ランダムで指の角度情報をセットする
//パーツごとにカラフルver
import ppopupmenu.*;
import processing.opengl.*;

int dim =3;  //関節(可動部)の数
int num = 5; //指そのものの数
int x = 0, y=0, z=0, i=0,c=0;
float fwidth = 13 , fheight = 26;  //指の太さと腹の長さを定義
float  deg[][][] = new float[num][dim][3];    //関節ごとの回転角度
//ここからデプスマップ用
int X=300,Y=300;
float depthmap[][] = new float[X+1][Y+1];
float depthmodel[][] = new float[X+1][Y+1];
int sx,sy;
float posx,posy,posz;
float def;  //デプス差格納用

/*----回転角度の内訳
deg[num][dim][3]とは、
deg[何本目の指か][根元から何番目の関節か][0:X軸、1:Y軸、2:Z軸の回転角]という意味
----numの内訳-----
0･･･親指 
1･･･人差し指
2･･･中指
3･･･薬指
4･･･小指   
-------------------*/

float  degrotate[] = new float[3];  //手そのものの旋回角 
float  pos[][][] = new float[num][dim+1][3];  //関節ごとの3次元座標


//接触(クリック)判定とポップアップ用
//Picker indexpicker,middlepicker;

//データやり取り用
PrintWriter output;
BufferedReader reader;


void setup(){
  size(X,Y,OPENGL);
  frameRate(90);
  initialize();
  fill(212,154,110);
}


void draw(){
  background(125);
  initmap();  
  translate(width/2-20, height/2+60);
  translate(0,-fwidth*2,0);
  //軸の取り方をイメージしやすい形に変更
  rotateX(radians(180));
  
  //ここから手のひらのモデリング
  
  //旋回！
  rotateX(radians(degrotate[0]));
  rotateY(radians(degrotate[1]));
  rotateZ(radians(degrotate[2]));
  
  //下部分
  fill(255,200,0);
  pushMatrix();
  rotateZ(radians(10));
  translate(fwidth*0.2,fwidth*1.7);
  pushMatrix();
  scale(4.0,0.1,1.2);
  float s=1.0;
  //円筒の奥行きを広げていきながら、ベース部分を描画
  for(i=0;i<40;i++){
    scale(1.0,1.0,s);
    //cylinder(36,fwidth,fwidth,fwidth);
    drawcylinder(36,fwidth,fwidth,fwidth,false);
    translate(0,-fwidth,fwidth/(100));
    scale(1.0,1.0,1/s);
    s+=0.020;
  }
  scale(1.0,18.0,s);
  translate(0,-fwidth*0.15);
  rotateZ(radians(-10));
  fill(255,80,0);
  //sphere(fwidth);
  drawsphere(fwidth);
  popMatrix();

  popMatrix();
  
  //上部分
  pushMatrix();
  translate(0,fwidth*1.5);
  fill(255,80,0);
  translate(0,fwidth*0.4);
  pushMatrix();
  rotateZ(radians(10));
  scale(4.0,2.0,1.2);  //球を引き延ばして楕円球に
  //sphere(fwidth);
  drawsphere(fwidth);
  popMatrix();
  
  //ここから親指以外の指のモデリング(sphere･･･関節、cylinder･･･指の腹)
  rotateZ(radians(10));
  translate( fwidth*3,fwidth/2.5);
  rotateZ(radians(-10));  //一時的に楕円と軸を合わせてもどす
  drawFinger(1,dim);  //人差し指を描画
  rotateZ(radians(10));
  translate(-(fwidth*2), fwidth);
  rotateZ(radians(-10));
  drawFinger(2,dim);  //中指
  rotateZ(radians(10));
  translate(-fwidth*2, -fwidth/2);
  rotateZ(radians(-10));
  drawFinger(3,dim);  //薬指
  rotateZ(radians(10));
  translate(-fwidth*2,  -fwidth/2);
  rotateZ(radians(-10));
  drawFinger(4,dim);  //小指
  
  popMatrix();
  
  //ここから親指のモデリング
  pushMatrix();
  //根元のモデリング(動く角度はZ軸方向)
  translate(fwidth*2.8,-fwidth*1.3);
  rotateZ(radians(-45));
  translate(fwidth*0.5,fwidth*0.5);
  rotateZ(radians(deg[0][0][2]));
  rotateX(radians(deg[0][0][0]));  //根元の可動角度を決定
  
  pushMatrix();
  scale(1.8,2.5,1.2);
  translate(0,0,0);
  fill(255,80,0);
  //fill(255,0,0);
  //sphere(fwidth);
  drawsphere(fwidth);
  popMatrix();
  
  //指のモデリング
  translate(0,fwidth*2,-fwidth/3);
  rotateY(radians(50));
  drawFinger(0,dim);
  popMatrix();
  //drawmap();
}

//マウスクリック時の処理
void mouseClicked() {
  //以下デバッグ用
  if(mouseButton == LEFT){
    println("Frate " + frameRate);
    println(depthmap[int(mouseX)][int(mouseY)]);
    println(mouseX + "  " +mouseY);
  }
  else if(mouseButton == RIGHT){
    modelread();
  }
}

void keyPressed(){       //キーが押された時の処理
  if(key == 'r'){    
    //println("Random deg set." + c);
    randomize_finger();
    c++;
  }
  else if(key == 'i'){
    initialize();
    c=0;
  }
  else if(key == 'g'){
    gset();
    println("ぐー");
  }
  else if(key == 'c'){
    cset();
    println("ちー");
  }
  else if(key == 'p'){
    pset();
    println("ぱー");
  }
  else if(key == 'e'){
    ex1();
  }
  else if(key == 'a'){  //カメラリセットもどき
    camera();
  }
}


//指描画関数
void drawFinger(int j, int maxdim){
  i=0;
  if(j==0){i=1;}
  pushMatrix();
  for(i=i;i<maxdim;i++){ 
     
    //fill(212,154,110);  //肌色で描画
    fill(0,255,0);  
    //fill(255,0,0);
    //関節ごとの回転角を適用
    rotateX(radians(deg[j][i][0]));
    rotateY(radians(deg[j][i][1]));
    rotateZ(radians(deg[j][i][2]));
    //sphere(fwidth);
    drawsphere(fwidth);
    
    //それぞれの関節の3次元座標を格納
    pos[j][i][0] = modelX(0.0,0.0,0.0);
    pos[j][i][1] = modelY(0.0,0.0,0.0);
    pos[j][i][2] = modelZ(0.0,0.0,0.0);
    translate(0,fwidth);      
    
    //fill(212,154,110);
    fill(0,0,255);
    if(i != maxdim-1){
      //cylinder(36,fheight,fwidth,fwidth);
      drawcylinder(36,fheight,fwidth,fwidth,false);
      translate(0,(fheight/2));
    }
    else{  //指先だけ少し長さを短く
      //cylinder(36,fheight*0.83,fwidth,fwidth);
      drawcylinder(36,fheight,fwidth,fwidth,false);
      translate(0,(fheight*0.5*0.83));
    }
  }
  //指先描画
  //fill(212,154,110);
  fill(0,255,0);
  //sphere(fwidth);
  drawsphere(fwidth);
  pos[j][i][0] = modelX(0.0,0.0,0.0);
  pos[j][i][1] = modelY(0.0,0.0,0.0);
  pos[j][i][2] = modelZ(0.0,0.0,0.0);
  popMatrix();
}


//多角柱の作成用関数
void cylinder(int corner, float length, float radius1 , float radius2){
  float x, y, z; //座標
  float inc = 360.0 / corner;
  pushMatrix();

  //上面の作成
  beginShape(TRIANGLE_FAN);
  y = -length / 2;

  vertex(0, y, 0);
  for(float deg = 0; deg <= 360; deg = deg + inc){
    x = cos(radians(deg)) * radius1;
    z = sin(radians(deg)) * radius1;
    vertex(x, y, z);
  }
  endShape(); 

  //底面の作成
  beginShape(TRIANGLE_FAN);
  y = length / 2;
  vertex(0, y, 0);
  for(float deg = 0; deg <= 360; deg = deg + inc){
    x = cos(radians(deg)) * radius2;
    z = sin(radians(deg)) * radius2;
    vertex(x, y, z);
  }
  endShape();


  //側面の作成
  beginShape(TRIANGLE_STRIP);
  for(float deg = 0; deg <= 360; deg = deg + inc){
    x = cos(radians(deg)) * radius1;
    y = -length / 2;
    z = sin(radians(deg)) * radius1; 
    vertex(x, y, z);
    
    x = cos(radians(deg)) * radius2;
    y = length / 2;
    z = sin(radians(deg)) * radius2; 
    vertex(x, y, z);
  }
  endShape();
  popMatrix(); 
}




//初期値セット関数
void initialize(){
  int i,j,k;
  for(i=0;i<num;i++){
    for(j=0;j<dim;j++){
      for(k=0;k<3;k++){
        deg[i][j][k] = 0;
        pos[i][j][k] = 0.0;
      }
    }
    if(i<3){degrotate[i] = 0.0;}
  }
}

//ランダムに角度をセットする関数
void randomize_finger(){
  int i,j,k;
  initialize();
//それぞれの指の回転角をセット  
/*----回転角度の内訳
[何本目の指か][根元から何番目の関節か][0:X軸、1:Y軸、2:Z軸の回転角]
*/
  for(i=0;i<num;i++){
    for(j=0;j<dim;j++){
      for(k=0;k<3;k++){
       
       if(num != 0){  //親指以外の角度決め 
        if(j == 0){    //指の根っこの部分
          switch(k){
            case 0: deg[i][j][0] = random(-80,0); break;
            case 1: deg[i][j][1] = random(0); break;
            case 2: 
              if(i == 1){deg[i][j][2] = random(-30,10);}
              else if(i == 2){deg[i][j][2] = random(-20,10);} 
              else{deg[i][j][2] = random(-10,30);}
             break;
            default: break;
          }
        }
        else if(j < dim){    //それ以外の指の関節
          switch(k){
            case 0: deg[i][j][0] = random(-90,0); break;
            case 1: deg[i][j][1] = random(0); break;
            case 2: deg[i][j][1] = random(0); break;
            default: break;
          }
        }
       }
       
       else{    //親指の角度決め
         if(j == 0){    //指の根っこの部分
          switch(k){
            case 0: deg[i][j][0] = random(-90,0); break;
            case 1: deg[i][j][1] = random(0); break;
            case 2: deg[i][j][2] = random(0,45); break;
            default: break;
          }
        }
        else if(j < dim-1){    //それ以外の指の関節
          switch(k){
            case 0: deg[i][j][0] = random(-80,0); break;
            case 1: deg[i][j][1] = random(0); break;
            case 2: deg[i][j][1] = random(0); break;
            default: break;
          }
        }
       }
       
      }
    }
  }

  //手そのものの回転角を決定
  degrotate[0] = random(-80,10);  //X軸
  degrotate[1] = random(-180,0);  //Y軸
  degrotate[2] = random(-45,45);  //Z軸*/
}

void gset(){  //グーをセット
  initialize();
  for(i=1;i<4;i++){
    deg[i][0][0] = -80.0;
    deg[i][1][0] = -90.0;
  }
  for(i=0;i<3;i++){
    deg[4][i][0] = -80.0;
  }
  deg[0][0][2] = 0.0;
  deg[0][0][0] = -80.0;
  deg[0][1][0] = -80.0;
  deg[0][2][0] = -30.0;
}

void cset(){  //チョキをセット
  initialize();
  gset();
  for(i=0;i<dim;i++){
    deg[1][i][0] = 0;
    deg[2][i][0] = 0;
  }
  deg[1][0][2] = -20.0;
  deg[2][0][2] = 10.0;
  degrotate[2] = 10.0;
}

void pset(){  //パーをセット
  initialize();
  deg[1][0][2] = -20.0;
  deg[3][0][2] = 20.0;
  deg[4][0][2] = 30.0;
}

void ex1(){  //中間報告用
  cset();
  deg[0][0][2] = -10.0;
  deg[0][0][0] = -30.0;
  deg[0][1][0] = 0.0;
  deg[1][2][0] = -30.0;
  deg[2][2][0] = -30.0;
  deg[1][1][0] = -30.0;
  deg[2][1][0] = -30.0;
}



void initmap(){  //デプスマップ初期化
  int a,b,c;
  for(a=0;a<X;a++){
    for(b=0;b<Y;b++){
       depthmap[a][b] = -500.0;
    }
  }
}

//球+デプスの作成関数
void drawsphere(float r){
  int nowpos,phi,theta,sx,sy;
  int i;
  float posx,posy,posz,sz,dx,dy,dz;
  pushMatrix();
  sphere(r);
  for(phi=0;phi<360;phi+=3){  //角度φ
      for(theta=0;theta<180;theta+=3){  //角度θ
        pushMatrix();
        //極座標(r,φ,θ)を直交座標(x,y,z)に変換して座標移動
        translate(r*sin(radians(theta))*cos(radians(phi)),r*sin(radians(theta))*sin(radians(phi)),r*cos(radians(theta))); 
        depthcheck();
        popMatrix();
      }
   }
  popMatrix();
}

//円筒+デプスの作成関数
void drawcylinder(int corner, float length, float radius1 , float radius2, boolean fbase){
  int nowpos,phi,theta,sx,sy,r;
  int i;
  float posx,posy,posz,sz,dx,dy,dz;
  pushMatrix();
  cylinder(corner,length,radius1,radius2);
  
  //ベースの円筒描画の時はここはスキップする
  if(fbase == true){
  //上面のデプス作成
  pushMatrix();
  translate(0,-length/2,0);
  for(r=0;r<=radius1;r++){
    for(theta=0;theta<=360;theta++){
      pushMatrix();
      translate(r*cos(radians(theta)),0,r*sin(radians(theta)));
      depthcheck();
      popMatrix();
    }
  }
  popMatrix();
  
  //底面のデプス作成
  pushMatrix();
  translate(0,length/2,0);
  for(r=0;r<=radius2;r++){
    for(theta=0;theta<=360;theta++){
      pushMatrix();
      translate(r*cos(radians(theta)),0,r*sin(radians(theta)));
      depthcheck();
      popMatrix();
    }
  }
  popMatrix();
  }  //ここまでスキップ(底面と上面は絶対画面上に現れないので)
  
  //側面のデプスマップ作成
  pushMatrix();
  for(i=int(-length/2);i<=int(length/2);i++){
    for(theta=0;theta<=360;theta++){
      pushMatrix();
      translate(radius1*cos(radians(theta)),i,radius1*sin(radians(theta)));
      depthcheck();
      popMatrix();
    }
  }
  popMatrix();
  
  popMatrix();
}

void drawmap(){  //バイナリマップを基に描画
  int i,j,k;
  
  pushMatrix();
 
  popMatrix();

}

//デプスマップ更新関数
void depthcheck(){ 
  //現在のポイントのZ座標(深度)とスクリーン上でのX,Y座標を取得
  posz = modelZ(0,0,0);
  sx = int(screenX(0,0,0));
  sy = int(screenY(0,0,0));
        
  if((sx >= 0)  && (sy >= 0) && (sx <= X) && (sy <= Y)){  //エラー回避用の条件
     //深度がより近くの点があれば、その点のデプスマップを更新
     if(depthmap[sx][sy] <= posz){depthmap[sx][sy] = posz;}
  }
  //if((sx <= X) && (sy <= Y)){println("Error! nunber " + sx + sy);}
}

//デプス差導出用プログラム
void modelread(){
  def=0;
  int i=0,j=0;
  output = createWriter("depthres.txt");  //読み込んだデプスマップの結果ファイル作成(デバッグ用)
  String lines[];  //ファイルデータ格納用配列
  float datares[][] = new float[X+1][Y+1];
  lines = loadStrings("P3D_Finger_random_color_binary_mastor\\depth.txt");  //デプスマップの読み込み
  for(i=0; i<lines.length; i++){  //行の数だけループ
    float[] data = float(split(lines[i], ' '));  //スペース(" ")で行を分割、それぞれを配列に格納
    for(j=0;j<=Y;j++){
      datares[i][j] = data[j];  //デバッグ用
      def = def + (data[j] - depthmap[i][j]);
      output.print(data[j] + " ");  //結果の出力(デバッグ用)
    }
    output.print("\n");
  }
  output.flush();
  println("模倣用のデプスマップを読み込みました");
  output.close();
  println("デプス誤差の総和･･･" + def);
}
