close all
clear all

pkg load image


[fileName, pathName] = uigetfile({'*.jpg'}, 'Selecionar uma imagem do banco de imagens');
imagem = strcat(pathName, fileName);
original = imread(imagem);

%%%%%%%%%%%%%%%% PR�-PROCESSAMENTO %%%%%%%%%%%%%%%%%%%%%%%

colorida = imresize(original,0.5);

A = rgb2gray(original);

im = imresize(A,0.5); %Retornar imagem com metade do tamanho

for i=1:size(im,1)-6
  for j=1:size(im,2)-8
    if (im(i,j)> 180)
      bw(i,j) = 0;
    else
      bw(i,j)=1;
    end
  end
end


EE = [1 1 1 ; 1 1 1 ; 1 1 1];

B = imerode(bw,EE);

E = imdilate(B,EE);

E2 = imdilate(E,EE);

B = imdilate(E2,EE);

C = B;
for i=2:size(B,1)-1
  for j=2:size(B,2)-1
    vizA = [B(i-1,j-1) B(i-1,j) B(i-1,j+1)...
          B(i,j-1) B(i,j) B(i,j+1)...
          B(i+1,j-1) B(i+1,j) B(i+1,j+1)];
    vizA = sort(vizA, "ascend");
    C(i,j) = vizA(5);
  end
end

figure('Name','Imagem Binarizada')
imshow(C)

########## SEPARA��O DE OBJETOS #################

[imRotulos,qtdFolhas] = bwlabel(C);

rotulos = unique(imRotulos);

cont = 1;
for k=2:qtdFolhas+1
   for i=1:size(imRotulos,1)
      for j=1:size(imRotulos,2)
        if(rotulos(k) == imRotulos(i,j))
          imNova(i,j,cont) = 1;
        else
          imNova(i,j,cont) = 0;
        endif       
      endfor
    endfor
    cont++;
endfor

## SEGMENTA��O ##


imgcor = colorida;

for i=1:size(C,1)
  for j=1:size(C,2)
    if(C(i,j)==1)
      imgcor(i,j,:) = colorida(i,j,:);
    else
      imgcor(i,j,:) = 0;
    endif
  endfor
endfor

figure(20)
imshow(imgcor)


################ ANALISE DE COMPRIMETOS ####################

areas = zeros(1,qtdFolhas);
perimetro = zeros(1,qtdFolhas);
eixoMaior = zeros(1,qtdFolhas);
eixoMenor = zeros(1,qtdFolhas);

for i=1:qtdFolhas
   areaRP(1,i) = regionprops(imNova(:,:,i),"Area").Area;
   perimetro(1,i) = regionprops(imNova(:,:,i),"Perimeter").Perimeter;
   eixoMaior(1,i) = regionprops(imNova(:,:,i),"MajorAxisLength").MajorAxisLength;
   ec(1,i) = regionprops(imNova(:,:,i),"Eccentricity").Eccentricity;
endfor

areaOrd = sort(areaRP);
perimetroOrd = sort(perimetro);
eixoMaiorOrd = sort(eixoMaior);
areamoeda = pi*(1.25*1.25);
perimetromoeda = (pi*pi)*1.25;

medidaA = areaOrd(1,1)/areamoeda;
medidaP = perimetroOrd(1,1)/perimetromoeda;
medidaEMA = eixoMaiorOrd(1,1)/2.5;
%medidaEME = centroOrd(1,1)/areamoeda;

for x=1:qtdFolhas
    areaCM(1,x) = (areaRP(1,x)/medidaA);
    perimetroCM(1,x) = (perimetro(1,x)/medidaP);
    eixoMaiorCM(1,x) = (eixoMaior(1,x)/medidaEMA);
    essenticidade = ec(1,x);
    %centroCM(1,j) = (centro(1,j)/metricaEME)
endfor

################## DESCRITORES ####################

cont = 1;
for g=1:qtdFolhas
  if(areaCM(1,g) > 4.9)
    desc(cont,1) = areaCM(1,g);
    desc(cont,2) = perimetroCM(1,g);
    desc(cont,3) = eixoMaiorCM(1,g);
    desc(cont,4) = double(ec(1,g));
    cont = cont + 1;
   endif
endfor

#### Identifica��o ####
  
resultado = uint8(zeros(size(imNova,1), size(imNova,2), 3));
  
for i=1:size(imNova,1)
  for j=1:size(imNova,2)
    #for x=1:size(imNova,3)
        if C(i,j) == 1
           resultado(i,j,1) = imgcor(i,j,1);
           resultado(i,j,2) = imgcor(i,j,2);
           resultado(i,j,3) = imgcor(i,j,3);
        end
    #end
  end  
end 

disp("----------RESULTADOS--------------")

color = 0.5;

disp(strcat("Quantidade de Objetos =  ",num2str(qtdFolhas)))

cont2 = 1;
for i=1:qtdFolhas
  disp(strcat("\Folha: \t",num2str(i)))
  for j=1:imNova(1,i)+1
   disp(desc(cont2,:));
   if(desc(cont2,1) > 32.00 && desc(cont2,2) > 48.00 && desc(cont2,3) > 9.00 && desc(cont2,4) > 0.80)
      disp("Este foliolo petence a um pau Brasil")
      figure("Name", strcat("\Folha:  \t",num2str(i), "  Este foliolo petence a um pau Brasil"))
      imshow(imNova(:,:,i))
        colormap(jet), colorbar;
   else
      disp('Este foliolo nao pertence a um pau brasil')
      figure("Name", strcat("\Folha: \t",num2str(i),"  Este foliolo nao petence a um pau Brasil"))
      imshow(imNova(:,:,i))
      colormap(jet), colorbar;
   endif
   cont2 = cont2 + 1;
  endfor
endfor
