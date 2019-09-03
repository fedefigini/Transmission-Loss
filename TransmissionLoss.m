function tl = TransmissionLoss

    tl.set = @set;
    tl.paredSimple = @paredSimple;
    tl.sharp = @sharp;
    tl.davy = @davy;
    tl.iso = @iso;

end

function data = set(params, data)
    
    % FILTRADO
    switch params.filtrado
        case 'Octavas'
            data.frec = [31.5 63 125 250 500 1000 2000 4000 8000 16000];
            data.deltab = 0.707;
%             data.octave = 1;
        case 'Tercios'
            data.frec = [20 25 31.5 40 50 63 80 100 125 160 200 250 ...
                315 400 500 630 800 1000 1250 1600 2000 2500 3150 ...
                4000 5000 6000 8000 10000 12500 16000 20000];
            data.deltab = 0.236;
%             data.octave = 3;
    end
    
    % SETEO MATERIAL
    index = strcmp(data.raw(:,2),params.material);
    index = find(index==1);
    
    % CONSTANTES
    data.c0 = 343; % Velocidad del sonido en el aire
    data.p0 = 1.18; % Densidad del aire
    
    % VARIABLES MATERIALES TABLA
    data.p = data.raw{index,3}; % Densidad
    data.E = data.raw{index,4}; % Módulo de Young
    data.nint = data.raw{index,5}; % Factor total de pérdidas
    data.sigma = data.raw{index,6}; % Módulo de Poisson
    
    % VARIABLES MATERIALES CÁLCULOS
    data.ms = data.p*params.lz;
    data.B = (data.E*(params.lz^3))/(12*(1-data.sigma^2));
    data.fc = (data.c0^2/(2*pi))*sqrt(data.ms/data.B);
    data.fd = (data.E/(2*pi*data.p))*sqrt(data.ms/data.B);
    data.ntot = data.nint + data.ms./(485*sqrt(data.frec));
    data.a = ((pi*data.ms.*data.frec)./(data.p0*data.c0)).*(1-(data.frec./data.fc).^2);
    data.S = params.lx*params.ly;
    data.lambda = data.c0./data.frec;
    data.titaL = acos(sqrt((data.lambda)./(2*pi*sqrt(data.S))));
    data.lx = params.lx;
    data.ly = params.ly;
    data.lz = params.lz;
    data.f11 = (data.c0^2/(4*data.fc))*((1/(params.lx^2))+(1/(params.ly^2)));
%     data.cL = sqrt(data.E/data.p);
    data.sigma1 = 1./sqrt(1-(data.fc./data.frec));
    data.sigma1(data.fc>data.frec) = 0;
    data.sigma2 = 4*params.lx*params.ly.*(data.frec./data.c0).^2;
    data.sigma3 = sqrt((2*pi*(params.lx+params.ly).*data.frec)./(16*data.c0));
    
    data.lambdai = sqrt(data.frec./data.fc);
    data.lambdai(data.fc<data.frec) = 0;
    data.delta1 = ((1-data.lambdai.^2).*log((1+data.lambdai)./(1-data.lambdai))+2.*data.lambdai)...
        ./(4*pi^2.*((1-data.lambdai.^2).^1.5));
    ind = data.frec>data.fc/2;
    data.delta2(ind) = 0;
    data.delta2(~ind) = (8*data.c0.*(1-2.*((data.lambdai(~ind)).^2)))...
        ./((data.fc^2)*(pi^4)*params.lx*params.ly.*data.lambdai(~ind).*sqrt(1-(data.lambdai(~ind).^2)));
    
    if data.f11<=data.fc/2
        ind = find(data.frec>=data.fc);
        data.sigmai(ind) = data.sigma1(ind);
        ind = find(data.frec<data.fc);
        data.sigmai(ind) = ((2*(params.lx+params.ly)*data.c0)/(params.lx*params.ly*data.fc))...
            *data.delta1(ind)+data.delta2(ind);
        ind = data.frec<data.f11 & data.f11<data.fc/2 & data.sigmai>data.sigma2;
            data.sigmai(ind) = data.sigma2(ind);
    elseif data.f11>data.fc/2
        data.sigmai = data.sigma3;
        ind = find(data.frec<data.fc & data.sigma2<data.sigma3);
        data.sigmai(ind) = data.sigma2(ind);
        ind = find(data.frec>data.fc & data.sigma1<data.sigma3);
        data.sigmai(ind) = data.sigma1(ind);
    end
    
    % SIGMA F PARA LA ISO
    data.k0 = 2*pi.*data.frec./data.c0;
    data.lambdam = -0.964-(0.5+params.ly/(pi*params.lx))*log(params.ly/params.lx)...
        +(5*params.ly)/(2*pi*params.lx)-1./(4*pi*params.lx*params.ly.*data.k0.^2);
    data.sigmaf = 0.5*(log(data.k0.*sqrt(params.lx*params.ly))-data.lambdam);
    
    data.sigmai(data.sigmai>2) = 2;
    data.sigmaf(data.sigmaf>2) = 2;
    
%     % NUEVO DAVY
%     data.averages = 3;
%     data.ratio = data.frec./data.fc;
%     data.limit = 2^(1/(2*data.octave));
%     
%     j = 1:3;
%     data.factor = 2^((2*j-1-averages)./(2*averages*octave));    
%     data.normal = data.p0*data.c0./(pi*data.ms.*data.frec);
%     data.e = 2*lx*ly/(lx+ly);
%     data.cos2l = data.c0/(2*pi*data.e.*frec);
%     data.cos2l(data.cos2l>0.9) = 0.9;
%     
%     data.tau1 = data.normal.^2.*log((normal.^2+1)./(data.normal.^2+cos2l)); %Con logaritmo en base e (ln)
%     data.r = 1-1./data.ratio;
%     data.r(data.r<0) = 0;
%     
%     data.G = sqrt(data.r);
%     data.rad = sigma(data); 
%     
%     % SIGMA FUNCTION
%     data.w = 1.3;
%     data.beta = 0.234;
%     data.n = 2;
%     data.U = 2*(params.lx+params.ly);
%     data.twoa = 4*data.S/data.U;
%     data.k = 2*pi.*data.frec./data.c0;
%     data.f = data.w.*sqrt(pi./(data.k.*data.twoa));
%     data.f(data.f>1) = 1;
%     data.h = 1./(sqrt(data.k.*(data.twoa/pi))).*2/3 - data.beta;
%     data.q = 2*pi./(data.k.^2.*data.S);
%     data.qn = data.q.^data.n;
%     
%     ind = data.G < data.f;
%     data.alpha(ind) = data.h(ind)./data.f(ind)-1;
%     data.xn(ind) = (data.h(ind)-data.alpha(ind).*data.G(ind)).^data.n;
%     data.xn(~ind) = data.G(~ind).^data.n;
% 
%     data.rad = (data.xn+data.qn).^(-1/data.n);
%     
%     data.netatotal = data.ntot + data.rad.*data.normal;
%     
%     data.z = 2./data.netatotal;
%     data.y = atan(data.z)-atan(data.z.*(1-data.ratio));
%     data.tau2 = data.normal.^2.*data.rad.^2.*data.y./(2.*data.netatotal.*data.ratio);
%     
%     % SHEAR FUNCTION
%     data.omega = 2*pi*data.frec;
%     data.chi = (1+data.sigma)/(0.87+1.12*data.sigma);
%     data.chi = data.chi^2;
%     data.X = (data.lz^2)/12;
%     data.QP = data.E/(1-data.sigma^2);
%     data.C = -data.omega.^2;
%     data.B = data.C.*(1+2*data.chi/(1-data.sigma))*data.X;
%     data.A = data.X*data.QP/data.p;
%     data.kbcor2 = (-data.B+sqrt(data.B.^2-4*data.A.*data.C))./(2*data.A);
%     data.kb2 = sqrt(-data.C./data.A);
%     data.Gshear = data.E/(2*(1+data.sigma));
%     data.kT2 = -data.C.*(data.p*data.chi/data.Gshear);
%     data.kL2 = -data.C.*(data.p/data.QP);
%     data.kS2 = data.kT2+data.kL2;
%     data.ASI = 1 + data.X.*(data.kbcor2.*data.kT2./data.kL2-data.kT2);
%     data.ASI = data.ASI.^2;
%     data.BSI = 1 - data.X.*data.kT2 + data.kbcor2.*data.kS2./(data.kb2.^2);
%     data.CSI = sqrt(1 - data.X.*data.kT2 + data.kS2.^2./(4.*data.kb2.^2));
%     data.shear = data.ASI./(data.BSI.*data.CSI);
%     
%     data.tau2 = data.tau2 * data.shear;
%     
%     % SINGLE LEAF DAVY FUNCTION    
%     ind = data.frec<data.fc;
%     data.tau(ind) = data.tau1 + data.tau2;
%     data.tau(~ind) = data.tau2;
%     
%     data.singleLeaf = -10*log10(tau);
%     
%     
    
end

function Rsimple = paredSimple(data)

    % LEY DE MASA CORREGIDA
    index = find(data.frec>data.fc);
    Rsimple(index) = 20*log10(data.ms.*data.frec(index)) ...
        - 10*log10(pi./(4*data.ntot(index))) ...
        - 10*log10(data.fc./(data.frec(index)-data.fc))-47;
    
    % LEY DE MASA
    index = find((data.frec<data.fc) | (data.frec>data.fd));
    Rsimple(index) = 20*log10(data.ms.*data.frec(index))-47;

end

function Rsharp = sharp(data)

    % f < 0.5*fc
    index = find(data.frec<0.5*data.fc);
    Rsharp(index) = ...
        10*log10(1+(pi*data.ms*data.frec(index)/(data.p0*data.c0)).^2)-5.5;
    
    % f >= fc
    index = find(data.frec>=data.fc);
    R1 = 10*log10(1+(pi*data.ms.*data.frec(index)/(data.p0*data.c0)).^2)...
        + 10*log10(2.*data.ntot(index).*data.frec(index)/(pi*data.fc));
    R2 = 10*log10(1+(pi*data.ms.*data.frec(index)/(data.p0*data.c0)).^2)...
        - 5.5;
    Rsharp(index) = min(R1,R2);
    
    % INTERPOLACIÓN LINEAL
    index1 = find(data.frec<0.5*data.fc,1,'last');
    index2 = find(data.frec>=data.fc,1);
    slope = (Rsharp(index2)-Rsharp(index1))/(index2-index1);
    intercept = Rsharp(index1)-slope*index1;
    Rsharp(index1+1:index2-1) = intercept+slope*(index1+1:index2-1);

end

function Rdavy = davy(data)
    
    % f <= 0.8*fc
    index = find(data.frec<=0.8*data.fc);
   Rdavy(index) = 10*log10(1+((pi*data.ms.*data.frec(index))./(data.p0*data.c0)).^2)...
        + 20*log10(1-(data.frec(index)./data.fc).^2)...
        - 10*log10(log((1+data.a(index).^2)./(1+data.a(index).^2.*(cos(data.titaL(index)).^2))));
    
    % 0.8*fc < f < 0.95*fc
    index = find((data.frec>0.8*data.fc) & (data.frec<0.95*data.fc));
    R1 = 10*log10(1 + ((pi*data.ms.*data.frec(index))/(data.p0*data.c0)).^2)...
        + 20*log10(1-(data.frec(index)./data.fc).^2)...
        - 10*log10(log((1+data.a(index).^2)/(1+data.a(index).^2.*(cos(data.titaL(index)).^2))));
    R2 = 10*log10(1 + ((pi*data.ms.*data.frec(index))/(data.p0*data.c0)).^2)...
        + 10*log10(2*data.deltab.*data.ntot(index)/pi);
    Rdavy(index) = max(R1,R2);
    
    % 0.95*fc <= f <= 1.05*fc
    index = find((data.frec>=0.95*data.fc) & (data.frec<=1.05*data.fc));
    Rdavy(index) = 10*log10(1 + ((pi*data.ms.*data.frec(index))/(data.p0*data.c0)).^2)...
        + 10*log10(2*data.deltab.*data.ntot(index)/pi);
    
    % 1.05*fc < f <= 1.7*fc
    index = find((data.frec>1.05*data.fc) & (data.frec<=1.7*data.fc));
    R1 = 10*log10(1 + ((pi*data.ms.*data.frec(index))/(data.p0*data.c0)).^2)...
        + 10*log10((2.*data.ntot(index)./pi).*((data.frec(index)./data.fc)-1));
    R2 = 10*log10(1 + ((pi*data.ms.*data.frec(index))/(data.p0*data.c0)).^2)...
        + 10*log10(2*data.deltab.*data.ntot(index)/pi);
    Rdavy(index) = max(R1,R2);
    
    % f > 1.7*fc
    index = find(data.frec>1.7*data.fc);
    Rdavy(index) = 10*log10(1 + ((pi*data.ms.*data.frec(index))/(data.p0*data.c0)).^2)...
        + 10*log10((2.*data.ntot(index)./pi).*((data.frec(index)./data.fc)-1));
    
end

% function Rdavy = davy(data) 
% 
%     % NUEVO DAVY?
%     
%     avSingleLeaf = 0;    
%     aux = 10^(-singleLeafDavy(data)/10);
%     avSingleLeaf = avSingleLeaf + aux;
% 
%     ind = (data.ratio<1/limit) | (data.ratio>limit);
%     Rdavy(ind) = singleLeafDavy(data);
%     Rdavy(~ind) = -10*log10(avSingleLeaf/averages);
%     
% end
% 
% function singleLeaf = singleLeafDavy(data)
% 
%     
% 
% end

function Riso = iso(data)

    % f >= fc
    index = find(data.frec>=data.fc);
    Riso(index) = -10*log10((((2*data.p0*data.c0)./(2*pi*data.ms.*data.frec(index))).^2)...
        .*((pi*data.fc.*(data.sigmai(index)).^2)./(2.*data.ntot(index).*data.frec(index))));
    
    % f < fc
    index = find(data.frec<data.fc);
    Riso(index) = -10*log10((((2*data.p0*data.c0)./(2*pi*data.ms.*data.frec(index))).^2)...
        .*((2.*data.sigmaf(index))+(((data.lx+data.ly)^2)/(data.lx^2+data.ly^2))...
        .*(sqrt(data.fc./data.frec(index))).*(data.sigmai(index).^2./data.ntot(index))));

end