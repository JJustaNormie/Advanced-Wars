clear;
warning off;
pkg load retro_games;
pkg load image;

% [start select up down left right a b]

function Confirm(jogo, rep)
  for i=1:rep
    jogo.set_input([0 0 0 0 0 0 0]);
    jogo.step(10);
    jogo.set_input([0 0 0 0 0 0 1]);
    jogo.step(300);
  end
end

function Iniciar(jogo)
  jogo.step(2000);
  Confirm(jogo, 4);
  for i=1:8
    jogo.set_input([0 0 0 0 0 0 0]);
    jogo.step(10);
    jogo.set_input([0 0 0 0 0 1 0]);
    jogo.step(10);
  end
  jogo.set_input([0 0 0 0 0 0 1]);
  jogo.step(10);
  jogo.set_input([1 0 0 0 0 0 0]);
  jogo.step(120);
  Confirm(jogo, 4);
  jogo.set_input([0 0 0 0 0 1 0]);
  jogo.step(10);
  jogo.set_input([0 0 0 0 0 0 1]);
  Confirm(jogo, 8);
  jogo.set_input([0 0 0 0 0 1 0]);
  jogo.step(10);
  jogo.set_input([0 0 0 0 0 0 1]);
  jogo.step(10);
  Confirm(jogo, 9);
  jogo.set_input([0 0 1 0 0 0 0]);
  jogo.step(10);
  Confirm(jogo, 4);
end

function visao(img, tile, matrix, x, y)
  infantry=img(94:109,34:47,:);
  mech=img(95:109,49:64,:);

  corr=normxcorr2(infantry,tile);
  cand=corr>0.5;
  cand=imdilate(cand,ones(21));

  if(cand(1,1)==1)
    matrix(x,y)=1;
  end
end

jogo=load_rom('Advance Wars (USA).gba');
Iniciar(jogo)
telainit=jogo.get_image();
telainit=rgb2gray(telainit);

for i=1:50
  tela=jogo.get_image();
  map=zeros(10, 15);

  #imshow(bwimg);
  tile=tela(97:102,33:48,:);

  visao(telainit, tile, map, 3, 6)
  map
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
