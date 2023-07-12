unit Model.CustomMsgAlert;

interface

uses
  System.SysUtils,
  System.UITypes,
  System.Classes,
  FMX.Types,
  FMX.Controls,
  FMX.StdCtrls,
  FMX.Objects,
  FMX.Effects,
  FMX.Layouts,
  FMX.Forms,
  FMX.Graphics,
  FMX.Ani,
  FMX.VirtualKeyboard,
  FMX.Platform;

type
  TCallBackProc = procedure(Sender: TObject) of Object;
  TIconDialog = (Success, Warning, Error, Info, Question);

  TCustomMsg = class

  private
    FBackgroundOpacity: Single;
    FTagString, FTagString2: string;
    FTag, FTag2: Integer;
    FTagFloat, FTagFloat2: Double;
    FTagDate: TDateTime;
    Ficon: TIconDialog;
    Layout, LayoutBtn: TLayout;
    Fundo, RectMsg, RectBtn1, RectBtn2, RectIcon1, RectIcon2: TRectangle;
    Arco: TArc;
    LabelTitulo, LabelMensagem, LabelBtn1, LabelBtn2, LabelIcon: TLabel;
    AnimacaoArco, AnimacaoFundo: TFloatAnimation;
    CallBack1, CallBack2: TCallBackProc;
    procedure BtnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure BtnMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure CloseDialog(Sender: TObject);
    procedure EndAnimation(Sender: TObject);
    procedure ClickBtn1(Sender: TObject);
    procedure ClickBtn2(Sender: TObject);
    procedure EndAnimationArco(Sender: TObject);

  public
    constructor Create(const Frm: TForm);
    procedure Show(icon: TIconDialog; titulo, mensagem: string;
      TextoBtn1: string = 'OK'; CallBackBtn1: TCallBackProc = nil;
      TextoBtn2: string = ''; CallBackBtn2: TCallBackProc = nil);

  published
    property BackgroundOpacity: Single read FBackgroundOpacity
      write FBackgroundOpacity;
    property TagString: String read FTagString write FTagString;
    property TagString2: String read FTagString2 write FTagString2;
    property Tag: Integer read FTag write FTag;
    property Tag2: Integer read FTag2 write FTag2;
    property TagFloat: Double read FTagFloat write FTagFloat;
    property TagFloat2: Double read FTagFloat2 write FTagFloat2;
    property TagDate: TDateTime read FTagDate write FTagDate;
  end;

implementation

const
  ColorGreen: Cardinal = $FF35BD27;
  ColorRed: Cardinal = $FFE64D4D;
  ColorGray: Cardinal = $FFAAAAAA;
  ColorBlue: Cardinal = $FF3085D6;
  ColorOrange: Cardinal = $FFF3A867;
  ColorGondenRod: Cardinal = $FFDAA520;

  { TCustomMsg }

procedure TCustomMsg.BtnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  TRectangle(Sender).Opacity := 0.8;
end;

procedure TCustomMsg.BtnMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  TRectangle(Sender).Opacity := 1;
end;

procedure TCustomMsg.ClickBtn1(Sender: TObject);
begin
  RectMsg.Tag := 1;
  CloseDialog(Sender);
end;

procedure TCustomMsg.ClickBtn2(Sender: TObject);
begin
  RectMsg.Tag := 2;
  CloseDialog(Sender);
end;

procedure TCustomMsg.CloseDialog(Sender: TObject);
begin
  { Animacao de fundo }
  AnimacaoFundo.StartValue := 1;
  AnimacaoFundo.StopValue := 0;
  AnimacaoFundo.Duration := 0.15;
  AnimacaoFundo.PropertyName := 'Opacity';
  AnimacaoFundo.AnimationType := TAnimationType.&In;
  AnimacaoFundo.Interpolation := TInterpolationType.Circular;
  AnimacaoFundo.Start;
end;

constructor TCustomMsg.Create(const Frm: TForm);
begin
  { Propriedades }
  BackgroundOpacity := 0.7;

  { Painel de fundo opaco }
  Fundo := TRectangle.Create(Frm);
  Fundo.Opacity := 0;
  Fundo.Parent := Frm;
  Fundo.Align := TAlignLayout.Contents;
  Fundo.Fill.Color := TAlphaColorRec.Black;
  Fundo.Fill.Kind := TBrushKind.Solid;
  Fundo.Stroke.Kind := TBrushKind.None;
  Fundo.Visible := false;

  { Layout do fundo da mensagem }
  Layout := TLayout.Create(Frm);
  Layout.Opacity := 0;
  Layout.Parent := Frm;
  Layout.Align := TAlignLayout.Contents;
  Layout.Visible := false;

  { Retangulo da mensagem }
  RectMsg := TRectangle.Create(Frm);
  RectMsg.Opacity := 1;
  RectMsg.Fill.Color := $FFFFFFFF;
  RectMsg.Parent := Layout;
  RectMsg.Align := TAlignLayout.Center;
  RectMsg.Width := 280;
  RectMsg.Height := 400;
  RectMsg.Visible := true;
  RectMsg.Stroke.Kind := TBrushKind.None;
  RectMsg.XRadius := 6;
  RectMsg.YRadius := 6;

  { Arco animado }
  Arco := TArc.Create(Frm);
  Arco.Visible := true;
  Arco.Parent := RectMsg;
  Arco.Align := TAlignLayout.MostTop;
  Arco.Margins.Top := 40;
  Arco.Margins.Right := Trunc((RectMsg.Width - 110) / 2);
  Arco.Margins.Left := Arco.Margins.Right;
  Arco.Height := 110;
  Arco.EndAngle := 0;
  Arco.Stroke.Color := $FF35BD27;
  Arco.Stroke.Thickness := 3;
  Arco.StartAngle := -90;

  { Retangulo do icone }
  RectIcon1 := TRectangle.Create(Arco);
  RectIcon1.Opacity := 1;
  RectIcon1.Parent := Arco;
  RectIcon1.Align := TAlignLayout.Center;
  RectIcon1.Visible := true;
  RectIcon1.Height := 5;
  RectIcon1.Stroke.Kind := TBrushKind.None;
  RectIcon1.XRadius := 3;
  RectIcon1.YRadius := 3;

  { Retangulo do icone 2 }
  RectIcon2 := TRectangle.Create(Arco);
  RectIcon2.Opacity := 1;
  RectIcon2.Align := TAlignLayout.Center;
  RectIcon2.Parent := Arco;
  RectIcon2.Visible := true;
  RectIcon2.Height := 5;
  RectIcon2.Stroke.Kind := TBrushKind.None;
  RectIcon2.XRadius := 3;
  RectIcon2.YRadius := 3;

  { Label do icone }
  LabelIcon := TLabel.Create(Arco);
  LabelIcon.Parent := Arco;
  LabelIcon.Align := TAlignLayout.Client;
  LabelIcon.Font.Size := 30;
  LabelIcon.FontColor := ColorGray;
  LabelIcon.TextSettings.HorzAlign := TTextAlign.Center;
  LabelIcon.TextSettings.VertAlign := TTextAlign.Center;
  LabelIcon.StyledSettings := [TStyledSetting.Family, TStyledSetting.Style];
  LabelIcon.Text := '';
  LabelIcon.VertTextAlign := TTextAlign.Center;
  LabelIcon.Trimming := TTextTrimming.None;

  { Animacao do circulo do icone }
  AnimacaoArco := TFloatAnimation.Create(Frm);
  AnimacaoArco.Parent := Arco;
  AnimacaoArco.Delay := 0.1;
  AnimacaoArco.StartValue := 0;
  AnimacaoArco.StopValue := 360;
  AnimacaoArco.Duration := 0.4;
  AnimacaoArco.PropertyName := 'EndAngle';
  AnimacaoArco.AnimationType := TAnimationType.&In;
  AnimacaoArco.Interpolation := TInterpolationType.Circular;
  AnimacaoArco.OnFinish := EndAnimationArco;

  { Animacao Fundo }
  AnimacaoFundo := TFloatAnimation.Create(Layout);
  AnimacaoFundo.Parent := Layout;
  AnimacaoFundo.OnFinish := EndAnimation;

  { Label da mensagem }
  LabelMensagem := TLabel.Create(Frm);
  LabelMensagem.Parent := RectMsg;
  LabelMensagem.Align := TAlignLayout.Client;
  LabelMensagem.Margins.Top := 20;
  LabelMensagem.Margins.Left := 20;
  LabelMensagem.Margins.Right := 20;
  LabelMensagem.Font.Size := 15;
  LabelMensagem.Height := 60;
  LabelMensagem.Width := RectMsg.Width - 4;
  LabelMensagem.FontColor := $FF848484;
  LabelMensagem.TextSettings.HorzAlign := TTextAlign.Center;
  LabelMensagem.TextSettings.VertAlign := TTextAlign.Leading;
  LabelMensagem.StyledSettings := [TStyledSetting.Family, TStyledSetting.Style];
  LabelMensagem.Text := 'Sua mensagem foi enviada com sucesso';
  LabelMensagem.VertTextAlign := TTextAlign.Leading;
  LabelMensagem.Trimming := TTextTrimming.None;

  { Label do titulo }
  LabelTitulo := TLabel.Create(Frm);
  LabelTitulo.Parent := RectMsg;
  LabelTitulo.Align := TAlignLayout.Top;
  LabelTitulo.Margins.Top := 30;
  LabelTitulo.Margins.Left := 20;
  LabelTitulo.Margins.Right := 20;
  LabelTitulo.Font.Size := 19;
  LabelTitulo.Height := 25;
  LabelTitulo.Width := RectMsg.Width - 4;
  LabelTitulo.FontColor := $FF2C2C2C;
  LabelTitulo.TextSettings.HorzAlign := TTextAlign.Center;
  LabelTitulo.TextSettings.VertAlign := TTextAlign.Leading;
  LabelTitulo.StyledSettings := [TStyledSetting.Family, TStyledSetting.Style];
  LabelTitulo.VertTextAlign := TTextAlign.Leading;
  LabelTitulo.Trimming := TTextTrimming.None;

  { Layout dos botoes }
  LayoutBtn := TLayout.Create(Frm);
  LayoutBtn.Parent := RectMsg;
  LayoutBtn.Align := TAlignLayout.Bottom;
  LayoutBtn.Height := 50;
  LayoutBtn.Margins.Left := 10;
  LayoutBtn.Margins.Right := 10;
  LayoutBtn.Margins.Bottom := 25;

  { Retangulo botao 1 }
  RectBtn1 := TRectangle.Create(Frm);
  RectBtn1.Opacity := 1;
  RectBtn1.Fill.Color := ColorGondenRod; // ColorBlue;
  RectBtn1.Parent := LayoutBtn;
  RectBtn1.Align := TAlignLayout.None;
  RectBtn1.Width := 190;
  RectBtn1.Height := 50;
  RectBtn1.Stroke.Kind := TBrushKind.None;
  RectBtn1.XRadius := 4;
  RectBtn1.YRadius := 4;
  RectBtn1.OnMouseDown := Self.BtnMouseDown;
  RectBtn1.OnMouseUp := Self.BtnMouseUp;
  RectBtn1.OnClick := ClickBtn1;
  RectBtn1.Visible := false;

  { Label botao 2 }
  LabelBtn1 := TLabel.Create(Frm);
  LabelBtn1.Parent := RectBtn1;
  LabelBtn1.Align := TAlignLayout.Contents;
  LabelBtn1.Font.Size := 17;
  LabelBtn1.FontColor := $FFFFFFFF;
  LabelBtn1.TextSettings.HorzAlign := TTextAlign.Center;
  LabelBtn1.TextSettings.VertAlign := TTextAlign.Center;
  LabelBtn1.StyledSettings := [TStyledSetting.Family, TStyledSetting.Style];
  LabelBtn1.Text := 'Enviar';
  LabelBtn1.VertTextAlign := TTextAlign.Center;
  LabelBtn1.Trimming := TTextTrimming.None;
  LabelBtn1.HitTest := false;

  { Retangulo botao 2 }
  RectBtn2 := TRectangle.Create(Frm);
  with RectBtn2 do
  begin
    Opacity := 1;
    Fill.Color := ColorBlue;
    Parent := LayoutBtn;
    Align := TAlignLayout.None;
    Width := 190;
    Height := 50;
    Stroke.Kind := TBrushKind.None;
    XRadius := 4;
    YRadius := 4;
    OnMouseDown := Self.BtnMouseDown;
    OnMouseUp := Self.BtnMouseUp;
    OnClick := ClickBtn2;
    Visible := false;
  end;

  { label botao 2 }
  LabelBtn2 := TLabel.Create(Frm);
  with LabelBtn2 do
  begin
    Parent := RectBtn2;
    Align := TAlignLayout.Contents;
    Font.Size := 17;
    FontColor := $FFFFFFFF;
    TextSettings.HorzAlign := TTextAlign.Center;
    TextSettings.VertAlign := TTextAlign.Center;
    StyledSettings := [TStyledSetting.Family, TStyledSetting.Style];
    Text := 'Cancelar';
    VertTextAlign := TTextAlign.Center;
    Trimming := TTextTrimming.None;
    HitTest := false;
  end;
end;

procedure TCustomMsg.EndAnimation(Sender: TObject);
begin
  Fundo.Visible := false;
  Layout.Visible := false;

  if RectMsg.Tag = 1 then
    if Assigned(CallBack1) then
      CallBack1(Self);

  if RectMsg.Tag = 2 then
    if Assigned(CallBack2) then
      CallBack2(Self);
end;

procedure TCustomMsg.EndAnimationArco(Sender: TObject);
begin
  {Desenha icone sucesso}
  if Ficon = TIconDialog.Success then
  begin
    RectIcon1.Margins.Right := 38;
    RectIcon1.Margins.Top := 21;
    RectIcon1.RotationAngle := 45;

    RectIcon2.Margins.Left := 20;
    RectIcon2.RotationAngle := 135;

    RectIcon1.AnimateFloat('Width', 30, 0.1);
    RectIcon2.AnimateFloatDelay('Width', 60, 0.1, 0.1);
  end;

  {Desenha icone erro}
  if Ficon = TIconDialog.Error then
  begin
    RectIcon1.Margins.Right := 0;
    RectIcon1.Margins.Top := 0;
    RectIcon1.RotationAngle := 45;
    RectIcon2.RotationAngle := 135;
    RectIcon2.Margins.Left := 0;

    RectIcon1.AnimateFloat('Width', 60, 0.1);
    RectIcon2.AnimateFloatDelay('Width', 60, 0.1, 0.1);
  end;

  {Desenha icone warning}
  if Ficon = TIconDialog.Warning then
  begin
    LabelIcon.Margins.Bottom := 5;
    LabelIcon.Text := '!';
    LabelIcon.Font.Size := 70;
  end;

  {Desenha icone info}
  if Ficon = TIconDialog.Info then
  begin
    LabelIcon.Margins.Bottom := 5;
    LabelIcon.Text := 'i';
    LabelIcon.Font.Size := 70;
  end;

 {Desenha icone question}
  if Ficon = TIconDialog.Question then
  begin
    LabelIcon.Margins.Bottom := 5;
    LabelIcon.Text := '?';
    LabelIcon.Font.Size := 70;
  end;

end;

procedure TCustomMsg.Show(icon: TIconDialog;
  titulo, mensagem, TextoBtn1: string; CallBackBtn1: TCallBackProc;
  TextoBtn2: string; CallBackBtn2: TCallBackProc);
begin
  var
    FService: IFMXVirtualKeyboardService;
  begin
   {icones}
    RectIcon1.Width := 0;
    RectIcon2.Width := 0;
    LabelIcon.Text := '';

    if icon = TIconDialog.Question then
    begin
      Arco.Stroke.Color := ColorGray;
      RectIcon1.Fill.Color := ColorGray;
      RectIcon2.Fill.Color := ColorGray;
      LabelIcon.FontColor := ColorGray;
    end
    else if icon = TIconDialog.Warning then
    begin
      Arco.Stroke.Color := ColorOrange;
      RectIcon1.Fill.Color := ColorOrange;
      RectIcon2.Fill.Color := ColorOrange;
      LabelIcon.FontColor := ColorOrange;
    end
    else if icon = TIconDialog.Error then
    begin
      Arco.Stroke.Color := ColorRed;
      RectIcon1.Fill.Color := ColorRed;
      RectIcon2.Fill.Color := ColorRed;
    end
    else if icon = TIconDialog.Info then
    begin
      Arco.Stroke.Color := ColorBlue;
      RectIcon1.Fill.Color := ColorBlue;
      RectIcon2.Fill.Color := ColorBlue;
      LabelIcon.FontColor := ColorBlue;
    end
    else
    begin
      Arco.Stroke.Color := ColorGreen;
      RectIcon1.Fill.Color := ColorGreen;
      RectIcon2.Fill.Color := ColorGreen;
    end;
    Ficon := icon;

    {Ajustes visuais}
    Fundo.Opacity := 0;
    Layout.Opacity := 0;
    Fundo.Visible := true;
    Layout.Visible := true;

    LabelTitulo.Text := titulo;
    LabelMensagem.Text := mensagem;
    LabelBtn1.Text := TextoBtn1;
    LabelBtn2.Text := TextoBtn2;

    {Verifica quais botoes exibir}
    RectBtn1.Visible := LabelBtn1.Text <> '';
    RectBtn2.Visible := LabelBtn2.Text <> '';

    if (RectBtn1.Visible) and (RectBtn2.Visible) then
    begin
      RectBtn1.Align := TAlignLayout.Left;
      RectBtn2.Align := TAlignLayout.Right;

      RectBtn1.Width := (LayoutBtn.Width / 2) - 6;
      RectBtn2.Width := RectBtn1.Width;
    end
    else if (RectBtn1.Visible) then
    begin
      RectBtn1.Align := TAlignLayout.Center;
      RectBtn1.Width := LayoutBtn.Width - 30;
    end;

    {Callbacks}
    CallBack1 := CallBackBtn1;
    CallBack2 := CallBackBtn2;

    {nimacao do icone}
    Arco.EndAngle := 0;
    AnimacaoArco.Start;

    {Exibe a mensagem}
    Fundo.AnimateFloat('Opacity', BackgroundOpacity, 0.15);
    Layout.AnimateFloatDelay('Opacity', 1, 0.3, 0.2);
    RectMsg.BringToFront;

    {Esconde o teclado virtual se estiver visivel}
    TPlatformServices.Current.SupportsPlatformService
      (IFMXVirtualKeyboardService, IInterface(FService));
    if (FService <> nil) then
    begin
      FService.HideVirtualKeyboard;
    end;
    FService := nil;
  end;
end;

end.