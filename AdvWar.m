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

function [matriz, quant]=visao(img, matrix)

  infantry=img(94:109,34:47,:);
  mech=img(95:109,49:64,:);
  recon=img(127:141,19:31,:);
  Ltank=img(82:93,19:30,:);
  apc=img(129:141,34:47,:);
  artillery=img(96:109,2:16,:);

  final=zeros(160,240);

  final=detect(img, infantry, final, 15, 13);
  final=detect(img, mech, final, 14, 15);
  final=detect(img, recon, final, 14, 12);
  final=detect(img, Ltank, final, 11, 11);
  final=detect(img, apc, final, 12, 13);
  final=detect(img, artillery, final, 13, 14);

  quant=0;
  for i=1:10
    for j=1:15
      if final((16*i)-8,(16*j)-8,:)>0
        matriz(i,j,:)=1;
        quant=quant+1;
      else
        matriz(i,j,:)=0;
      end
    endfor
  endfor
end

% [start select up down left right a b]

function UnitMove(Dist, jogo)
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

  jogo.set_input([0 0 0 0 0 0 1 0]);
  jogo.step(10);
  jogo.set_input([0 0 0 0 0 0 0 0]);
  jogo.step(10);

  tela=jogo.get_image();
  img=rgb2hsv(tela);
  V=img(:,:,3);
  Range=(V>0.95);

  imshow(Range);
  drawnow;
  pause
end

function cursor=movement(quant, cursor, matrix, jogo)
  for i=1:quant
    pos=[0,0];
    for i=1:10
      for j=1:15
        if matrix(i,j)==1
          pos=[i,j]
          break;
        end
      end
      if matrix(i,j)==1
        break;
      end
    end
    Dist=pos-cursor;

    UnitMove(Dist, jogo)
  endfor
end

jogo=load_rom('Advance Wars (USA).gba');
Iniciar(jogo)
telainit=jogo.get_image();
telainit=rgb2gray(telainit);
map=zeros(10, 15);
cursor=[9,1]

for i=1:50
  tela=jogo.get_image();

  [map,quant]=visao(telainit, map);

  cursor=movement(quant, cursor, map, jogo);
  imshow(tela);
  drawnow;
  pause

  img=rgb2hsv(tela);
  H=img(:,:,1);
  V=img(:,:,3);
  Allies=(H==0);
  Fog=(V>0.8);
  Fog(1:48,144:end)=0;
  Fog(1:48,208:end)=0;
  #Allies = imdilate(Allies,ones(3));

  imshow(tela);
  drawnow;
  hold off
end
