clear;
warning off;
pkg load retro_games;
pkg load image;

% [start select up down left right a b]

function Confirm(jogo, rep)
  for i=1:rep
    jogo.set_input([0 0 0 0 0 0 0 0]);
    jogo.step(10);
    jogo.set_input([0 0 0 0 0 0 1 0]);
    tela=jogo.get_image();
    imshow(tela);
    drawnow;
    jogo.step(300);
  end
end

function Iniciar(jogo)
  jogo.step(2000);
  Confirm(jogo, 4);
  for i=1:8
    jogo.set_input([0 0 0 0 0 0 0 0]);
    jogo.step(10);
    jogo.set_input([0 0 0 0 0 1 0 0]);
    jogo.step(10);
  end
  jogo.set_input([0 0 0 0 0 0 1 0]);
  jogo.step(10);
  jogo.set_input([1 0 0 0 0 0 0 0]);
  jogo.step(120);
  Confirm(jogo, 4);
  jogo.set_input([0 0 0 0 0 1 0 0]);
  jogo.step(10);
  jogo.set_input([0 0 0 0 0 0 1 0]);
  Confirm(jogo, 8);
  jogo.set_input([0 0 0 0 0 1 0 0]);
  jogo.step(10);
  jogo.set_input([0 0 0 0 0 0 1 0]);
  jogo.step(10);
  Confirm(jogo, 9);
  jogo.set_input([0 0 1 0 0 0 0 0]);
  jogo.step(10);
  Confirm(jogo, 4);
end

function final=detect(img, pad, final, y, x)
  x=floor(x/2);
  y=floor(y/2);

  corr=normxcorr2(pad,img);
  cand=corr>0.5;
  cand=imdilate(cand,ones(16));
  final=final+cand((1+y):(160+y),(1+x):(240+x),:);
end

function moving(Dist,jogo)
  if Dist(1)<0
    for i=1:sqrt(Dist(1)*Dist(1))
      jogo.set_input([0 0 1 0 0 0 0 0]);
      jogo.step(10);
      jogo.set_input([0 0 0 0 0 0 0 0]);
      jogo.step(10);
    endfor
  endif
  if Dist(1)>0
    for i=1:sqrt(Dist(1)*Dist(1))
      jogo.set_input([0 0 0 1 0 0 0 0]);
      jogo.step(10);
      jogo.set_input([0 0 0 0 0 0 0 0]);
      jogo.step(10);
    endfor
  endif
  if Dist(2)<0
    for i=1:sqrt(Dist(2)*Dist(2))
      jogo.set_input([0 0 0 0 1 0 0 0]);
      jogo.step(10);
      jogo.set_input([0 0 0 0 0 0 0 0]);
      jogo.step(10);
    endfor
  endif
  if Dist(2)>0
    for i=1:sqrt(Dist(2)*Dist(2))
      jogo.set_input([0 0 0 0 0 1 0 0]);
      jogo.step(10);
      jogo.set_input([0 0 0 0 0 0 0 0]);
      jogo.step(10);
    endfor
  endif
end

function [tela1,tela2,cursor]=getimages(cursor,jogo)
  pt1=[6,4];
  pt2=[6,12];

  Dist=pt1-cursor;
  cursor=pt1;
  moving(Dist,jogo);
  tela1=jogo.get_image();

  Dist=pt2-cursor;
  cursor=pt2;
  moving(Dist,jogo);
  tela2=jogo.get_image();
end

function [matriz, quant]=visao(imginit, img1, img2, matrix)

  infantry=imginit(94:109,34:47,:);
  mech=imginit(95:109,49:64,:);
  recon=imginit(127:141,19:31,:);
  Ltank=imginit(82:93,19:30,:);
  apc=imginit(129:141,34:47,:);
  artillery=imginit(96:109,2:16,:);

  final=zeros(160,240);

  final=detect(img1, infantry, final, 15, 13);
  final=detect(img1, mech, final, 14, 15);
  final=detect(img1, recon, final, 14, 12);
  final=detect(img1, Ltank, final, 11, 11);
  final=detect(img1, apc, final, 12, 13);
  final=detect(img1, artillery, final, 13, 14);

  final=detect(img2, infantry, final, 15, 13);
  final=detect(img2, mech, final, 14, 15);
  final=detect(img2, recon, final, 14, 12);
  final=detect(img2, Ltank, final, 11, 11);
  final=detect(img2, apc, final, 12, 13);
  final=detect(img2, artillery, final, 13, 14);

  imshow(final);
  drawnow;
  pause;
  matriz=zeros(10, 15);

  quant=0;
  for i=1:10
    for j=1:15
      if final((16*i)-8,(16*j)-8,2)>0|final((16*i)-8,(16*j)-8,1)>0|final((16*i)-8,(16*j)-8,3)>0
        matriz(i,j,:)=1;
        quant=quant+1;
      end
    endfor
  endfor
end

% [start select up down left right a b]

function [posf,matrix]=UnitMove(Dist, pos, matrix, jogo)
  posinit=pos;
  moving(Dist,jogo);
  tela=rgb2gray(jogo.get_image());

  jogo.set_input([0 0 0 0 0 0 1 0]);
  jogo.step(10);
  jogo.set_input([0 0 0 0 0 0 0 0]);
  jogo.step(10);

  telacomp=rgb2gray(jogo.get_image());
  moveop = telacomp - tela;

  for i=1:10
    for j=1:15
      if matrix(i,j)>0
        moveop((i*16)-8,(j*16)-8,:)=0;
      end
    end
  end

  if pos(2)<8
    matmov=zeros(10,8);
    for i=1:10
      for j=1:7
        if moveop((i*16)-8,(j*16)-8,:)>0
          matmov(i,j)=3;
        end
      end
    end
    desloc=pos;
    menor=[99,99];
    alvo=[2,15];
    for i=1:10
      for j=1:7
        if matmov(i,j)==3;
          itar=sqrt((i-alvo(1))*(i-alvo(1)));
          jtar=sqrt((alvo(2)-j)*(alvo(2)-j));
          if itar+jtar<menor(1)+menor(2)
            menor(1)=itar;
            menor(2)=jtar;
            desloc=[i,j];
          endif
        end
      end
    end
  endif
  if pos(2)>|
    matmov=zeros(10,7);
    for i=1:10
      for j=1:8
        if moveop((i*16)-8,((j+7)*16)-8,:)>0
          matmov(i,j)=3;
        end
      end
    end
    desloc=pos;
    menor=[99,99];
    alvo=[2,15];
    for i=1:10
      for j=1:8
        if matmov(i,j)==3;
          itar=sqrt((i-alvo(1))*(i-alvo(1)));
          jtar=sqrt((alvo(2)-j)*(alvo(2)-j));
          if itar+jtar<menor(1)+menor(2)
            menor(1)=itar;
            menor(2)=jtar;
            desloc=[i,j];
          endif
        end
      end
    end
  endif
  if pos(2)>7
    matmov=zeros(10,7);
    for i=1:10
      for j=1:8
        if moveop((i*16)-8,((j+7)*16)-8,:)>0
          matmov(i,j)=3;
        end
      end
    end
    desloc=pos;
    menor=[99,99];
    alvo=[2,15];
    for i=1:10
      for j=1:8
        if matmov(i,j)==3;
          itar=sqrt((i-alvo(1))*(i-alvo(1)));
          jtar=sqrt((alvo(2)-j)*(alvo(2)-j));
          if itar+jtar<menor(1)+menor(2)
            menor(1)=itar;
            menor(2)=jtar;
            desloc=[i,j];
          endif
        end
      end
    end
  endif

  Dist=desloc-pos;
  pos=desloc;

  moving(Dist,jogo);

  if posinit(1)==pos(1)&posinit(2)==pos(2)
    jogo.set_input([0 0 0 0 0 0 0 1]);
    jogo.step(10);
    jogo.set_input([0 0 0 0 0 0 0 0]);
    jogo.step(60);
  else
    jogo.set_input([0 0 0 0 0 0 1 0]);
    jogo.step(10);
    jogo.set_input([0 0 0 0 0 0 0 0]);
    jogo.step(60);
    jogo.set_input([0 0 0 0 0 0 1 0]);
    jogo.step(10);
    jogo.set_input([0 0 0 0 0 0 0 0]);
    jogo.step(300);
  endif

  tela=jogo.get_image();
  imshow(tela);
  drawnow;
  pause;
  matrix(pos(1), pos(2)) = 2;
  posf=pos;
end

function cursor=movement(quant, cursor, matrix, jogo)
  for i=1:quant
    pos=[0,0];
    for i=1:10
      for j=1:15
        if matrix(i,j)==1
          pos=[i,j];
          break;
        end
      end
      if matrix(i,j)==1
        break;
      end
    end
    Dist=pos-cursor;

    [posf, matrix]=UnitMove(Dist, pos, matrix, jogo);
    matrix(pos(1),pos(2))=0;
    cursor=posf;
  endfor
end

jogo=load_rom('Advance Wars (USA).gba');
Iniciar(jogo)
telainit=jogo.get_image();
telainit=rgb2gray(telainit);
map=zeros(10, 15);
cursor=[9,1];

for i=1:50
  [tela1,tela2,cursor]=getimages(cursor,jogo);
  [map,quant]=visao(telainit, tela1, tela2, map);
  map

  cursor=movement(quant, cursor, map, jogo);
  tela=jogo.get_image();
  imshow(tela);
  drawnow;

  jogo.set_input([0 0 0 0 0 0 0 1]);
  jogo.step(10);
  jogo.set_input([0 0 0 0 0 0 0 0]);
  jogo.step(300);
  jogo.set_input([0 0 0 0 0 0 1 0]);
  jogo.step(10);
  jogo.set_input([0 0 0 0 0 0 0 0]);
  jogo.step(3000);
  tela=jogo.get_image();
  imshow(tela);
  drawnow;

  jogo.set_input([0 0 1 0 0 0 0 0]);
  jogo.step(10);
  jogo.set_input([0 0 0 0 0 0 0 0]);
  jogo.step(10);
  jogo.set_input([0 0 0 0 0 0 1 0]);
  jogo.step(10);
  jogo.set_input([0 0 0 0 0 0 0 0]);
  jogo.step(3000);
  tela=jogo.get_image();
  imshow(tela);
  drawnow;
  pause;
end
