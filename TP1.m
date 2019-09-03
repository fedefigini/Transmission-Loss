% HANDLES
handles = TransmissionLoss;

% MATFILE PARA LOS PARÁMETROS SETEADOS POR LA GUI
params = matfile('tp1.mat','Writable',true);

% DEFAULTS POR SI NO ABRO LOS POPUPS
params.material = 'Acero';
params.filtrado = 'Tercios';

% LIMPIO LAS MEDIDAS
params.lx = 0;
params.ly = 0;
params.lz = 0;

% LIMPIO LOS VALORES DE LOS FLAGS DE PLOTS
params.davy = 0;
params.sharp = 0;
params.paredSimple = 0;
params.iso = 0;

% CARGO LA TABLA DE MATERIALES
uiwait(helpdlg('Cargue la tabla de materiales','Help'));
filter = {'*.xls;*.xlsx;*.xlsm;*.xltx;*.xltm',...
    'Excel Files(*.xls,*.xlsx,*.xlsm,*.xltx,*.xltm'};
params.filename = uigetfile(filter,'Seleccione un archivo');
while params.filename == 0
    uiwait(errordlg('Cargue una tabla de materiales para comenzar','Error'));
    params.filename = uigetfile(filter,'Seleccione un archivo');
end

% LEO LA TABLA DE MATERIALES
[~, ~, data.raw] = xlsread(params.filename);

% CREO LA FIGURA
fig = figure('Name','TP1','NumberTitle','off',...
    'Position',[100 100 1200 600],'Resize','Off',...
    'MenuBar','none','ToolBar','figure','UserData',{data, handles});

% CREO LOS PANELES
OpcionesP = uipanel(fig,'Title','Opciones',...
    'Units','pixels','Position',[10 450 550 150]);
FuncionesP = uipanel(fig,'Title','Funciones',...
    'Units','pixels','Position',[560 450 280 150]);
MetodosP = uipanel(fig,'Title','Métodos de cálculo',...
    'Units','pixels','Position',[840 450 350 150]);
GraficosP = uipanel(fig,...
    'Units','pixels','Position',[10 10 1180 440]);

% BOTONES OPCIONES
MaterialTxt = uicontrol(OpcionesP,'Style','text',...
    'Position',[10 86 60 30],...
    'String','Material:');
MaterialBT = uicontrol(OpcionesP,'Style','popupmenu',...
    'Position',[70 90 200 30],...
    'String',data.raw(2:end,2));
FiltradoTxt = uicontrol(OpcionesP,'Style','text',...
    'Position',[280 86 60 30],...
    'String','Filtrado:');
FiltradoBT = uicontrol(OpcionesP,'Style','popupmenu',...
    'Position',[340 90 150 30],...
    'String',['Tercios';'Octavas']);
DimensionesTxt = uicontrol(OpcionesP,'Style','text',...
    'Position',[10 24 70 30],...
    'String','Dimensiones:');
AnchoTxt = uicontrol(OpcionesP,'Style','text',...
    'Position',[80 24 60 30],...
    'String','Ancho:');
AnchoBT = uicontrol(OpcionesP,'Style','edit',...
    'Position',[150 30 70 30]);
AltoTxt = uicontrol(OpcionesP,'Style','text',...
    'Position',[230 24 60 30],...
    'String','Alto:');
AltoBT = uicontrol(OpcionesP,'Style','edit',...
    'Position',[300 30 70 30]);
EspesorTxt = uicontrol(OpcionesP,'Style','text',...
    'Position',[380 24 60 30],...
    'String','Espesor:');
EspesorBT = uicontrol(OpcionesP,'Style','edit',...
    'Position',[450 30 70 30]);

% BOTONES FUNCIONES
ProcesarBT = uicontrol(FuncionesP,'Style','pushbutton',...
    'Position',[10 90 125 30],...
    'String','Procesar');
ExportarBT = uicontrol(FuncionesP,'Style','pushbutton',...
    'Position',[10 30 125 30],...
    'String','Exportar');
CargarBT = uicontrol(FuncionesP,'Style','pushbutton',...
    'Position',[145 90 125 30],...
    'String','Cargar');
BorrarBT = uicontrol(FuncionesP,'Style','pushbutton',...
    'Position',[145 30 125 30],...
    'String','Borrar');

% BOTONES METODOS
DavyBT = uicontrol(MetodosP,'Style','checkbox',...
    'Position',[15 90 155 30],...
    'String','Davy');
SharpBT = uicontrol(MetodosP,'Style','checkbox',...
    'Position',[15 30 155 30],...
    'String','Sharp');
ParedSimpleBT = uicontrol(MetodosP,'Style','checkbox',...
    'Position',[190 90 155 30],...
    'String','Pared Simple');
ISOBT = uicontrol(MetodosP,'Style','checkbox',...
    'Position',[190 30 155 30],...
    'String','ISO');

% GRÁFICOS
GraficosAX = axes(GraficosP,...
    'Units', 'pixels', 'OuterPosition',[30 30 1140 400],...
    'Position',[60 70 1100 340], 'XLim',[20 20000], 'XScale', 'log',...
    'XGrid','on','YGrid','on','GridLineStyle','--',...
    'XMinorTick','off','Color', [0.85 0.85 1], 'YLim', [0 inf]);
title(GraficosAX,'Gráficos');
xlabel(GraficosAX,'Frecuencias (Hz)');
ylabel(GraficosAX,'TL (dB)');

% CALLBACKS
MaterialBT.Callback = {@material, params, data};
FiltradoBT.Callback = {@filtrado, params};
AnchoBT.Callback = {@ancho, params};
AltoBT.Callback = {@alto, params};
EspesorBT.Callback = {@espesor, params};

ProcesarBT.Callback = {@procesar, params, data, handles, GraficosAX};
ExportarBT.Callback = {@exportar, params};
CargarBT.Callback = {@cargar, params, data, MaterialBT};
BorrarBT.Callback = {@borrar, params, MaterialBT, FiltradoBT, AnchoBT, AltoBT, EspesorBT,...
    DavyBT, SharpBT, ParedSimpleBT, ISOBT, GraficosAX};

DavyBT.Callback = {@davy, params};
SharpBT.Callback = {@sharp, params};
ParedSimpleBT.Callback = {@paredSimple, params};
ISOBT.Callback = {@iso, params};


function material(self, ~, params, data)

    params.material = data.raw{self.Value+1,2};

end

function filtrado(self, ~, params)

    switch self.Value
        case 1
            params.filtrado = 'Tercios';
        case 2
            params.filtrado = 'Octavas';
        otherwise
            error('El filtrado es por tercios u octavas');
    end

end

function ancho(self, ~, params)

    if strcmp(self.String,'Give')
        params.lx = self.String;
    else
        params.lx = str2double(self.String);
    end

end

function alto(self, ~, params)

    if strcmp(self.String,'You')
        params.ly = self.String;
    else    
        params.ly = str2double(self.String);
    end
    
end

function espesor(self, ~, params)

%     params.lz = self.String;
    
    if strcmp(self.String,'Up')
        params.lz = self.String;
    else    
        params.lz = str2double(self.String);
    end
    
end



function procesar(~, ~, params, data, handles, GraficosAX)
    
    if strcmp(params.lx,'Give') && strcmp(params.ly,'You') && strcmp(params.lz,'Up')
        web('https://www.youtube.com/watch?v=dQw4w9WgXcQ','-browser');
        msgbox('You have been rickrolled','Easter Egg','modal');
    else

        % CARGO LA TABLA, SETEO LAS DIMENSIONES Y EL FILTRADO
        data = handles.set(params, data);
        params.data = data;
        params.frec = data.frec;
        params.fc = data.fc;

        % PREPARO LOS PLOTS
        hold on;

        GraficosAX.XTick = data.frec;
        switch params.filtrado
            case 'Octavas'
                GraficosAX.XTickLabel = ...
                    {'31.5', '63', '125', '250', '500', '1000', '2000',...
                    '4000', '8000', '16000'};
            case 'Tercios'
                GraficosAX.XTickLabel = ...
                    {'20', '25', '31.5', '40', '50', '63', '80', '100', '125',...
                    '160', '200', '250', '315', '400', '500', '630', '800',...
                    '1000', '1250', '1600', '2000', '2500', '3150', '4000',...
                    '5000', '6000', '8000', '10000', '12500', '16000', '20000'};
        end
        GraficosAX.XTickLabelRotation = 45;

        i = 0;

        % MÉTODOS DE CÁLCULO DE R   
        if params.davy
            params.Rdavy = handles.davy(data);
            plot(GraficosAX,data.frec,params.Rdavy);
            i = i+1;
            labels(i) = {'Davy'};
        end

        if params.sharp
            params.Rsharp = handles.sharp(data);
            plot(GraficosAX,data.frec,params.Rsharp);
            i = i+1;
            labels(i) = {'Sharp'};
        end

        if params.paredSimple
            params.Rsimple = handles.paredSimple(data);
            plot(GraficosAX,data.frec,params.Rsimple);
            i = i+1;
            labels(i) = {'Pared Simple'};
        end

        if params.iso
            params.Riso = handles.iso(data);
            plot(GraficosAX,data.frec,params.Riso);
            i = i+1;
            labels(i) = {'ISO'};
        end

        legend(labels,'Location','southeast');
        hold off;
        
    end
    
end

function exportar(~, ~, params)

    % SI NO EXISTE EL .XLSX AVISO
    if exist('TP1.xlsx', 'file') == 0
        errordlg('No se encuentra el archivo TP1.xlsx en la carpeta del TP','Error');
    end
    
    % LIMPIO TODOS LOS VALORES PREVIOS
    void = '                               ';
    xlswrite('TP1.xlsx',void,'Resultados','B6:AF6');
    xlswrite('TP1.xlsx',void,'Resultados','B7:AF7');
    xlswrite('TP1.xlsx',void,'Resultados','B8:AF8');
    xlswrite('TP1.xlsx',void,'Resultados','B9:AF9');
    xlswrite('TP1.xlsx',void,'Resultados','B10:AF10');
    
    xlswrite('TP1.xlsx',{params.material},'Resultados','B3');
    xlswrite('TP1.xlsx',params.lx,'Resultados','C3');
    xlswrite('TP1.xlsx',params.ly,'Resultados','D3');
    xlswrite('TP1.xlsx',params.lz,'Resultados','E3');
    xlswrite('TP1.xlsx',round(params.fc,1),'Resultados','F3');
    
    xlswrite('TP1.xlsx',0,'Resultados','B7:AF10');
    
    % CHECKEO SI ESTÁ POR TERCIOS O POR OCTAVAS
    if params.filtrado == 'Tercios'
        xlswrite('TP1.xlsx',params.frec,'Resultados','B6:AF6');
    end
    if params.filtrado == 'Octavas'
        xlswrite('TP1.xlsx',params.frec,'Resultados','B6:K6');
    end
    
    % CHECKEO LOS FLAGS DE MÉTODOS
    if params.paredSimple == 1
        xlswrite('TP1.xlsx',round(params.Rsimple,2),'Resultados','B7:AF7');
    end
    if params.sharp == 1
        xlswrite('TP1.xlsx',round(params.Rsharp,2),'Resultados','B8:AF8');
    end
    if params.davy == 1
        xlswrite('TP1.xlsx',round(params.Rdavy,2),'Resultados','B9:AF9');
    end
    if params.iso == 1
        xlswrite('TP1.xlsx',round(params.Riso,2),'Resultados','B10:AF10');
    end

end

function cargar(~, ~, params, data, MaterialBT)

    % CARGO LA TABLA DE MATERIALES
    uiwait(helpdlg('Cargue la tabla de materiales','Help'));
    filter = {'*.xls;*.xlsx;*.xlsm;*.xltx;*.xltm',...
        'Excel Files(*.xls,*.xlsx,*.xlsm,*.xltx,*.xltm'};
    params.filename = uigetfile(filter,'Seleccione un archivo');
    if params.filename ~= 0
        [~, ~, data.raw] = xlsread(params.filename);
        MaterialBT.String = data.raw(2:end,2);
    end

end

function borrar(~, ~, params, MaterialBT, FiltradoBT, AnchoBT, AltoBT, EspesorBT,...
    DavyBT, SharpBT, ParedSimpleBT, ISOBT, GraficosAX)
    
    cla(GraficosAX);
    
    % LIMPIO LOS BOTONES
    MaterialBT.Value = 1;
    FiltradoBT.Value = 1;
    AnchoBT.String = '';
    AltoBT.String = '';
    EspesorBT.String = '';
    DavyBT.Value = 0;
    SharpBT.Value = 0;
    ParedSimpleBT.Value = 0;
    ISOBT.Value = 0;
    
    params.material = 'Acero';
    params.filtrado = 'Tercios';
    params.lx = 0;
    params.ly = 0;
    params.lz = 0;
    params.davy = 0;
    params.sharp = 0;
    params.paredSimple = 0;
    params.iso = 0;
    
end



function davy(self, ~, params)

    params.davy = self.Value;

end

function sharp(self, ~, params)

    params.sharp = self.Value;

end

function paredSimple(self, ~, params)

    params.paredSimple = self.Value;

end

function iso(self, ~, params)

    params.iso = self.Value;

end