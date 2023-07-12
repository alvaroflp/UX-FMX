unit Model.CustomComboBox;

interface

uses
  FMX.Layouts,
  FMX.Objects,
  FMX.Types,
  FMX.Forms,
  FMX.Graphics,
  FMX.Ani,
  FMX.StdCtrls,
  FMX.Dialogs,
  SysUtils,
  System.Types;

type
  TExecutaClickWin = procedure(Sender: TObject) of Object;
  TExecutaClickMobile = procedure(Sender: TObject; const Point: TPointF) of Object;

  TCustomCombo = class
  private
    rectFundo, rectItem: TRectangle;
    vert: TVertScrollBox;
    Ani: TFloatAnimation;
    btnBack: TSpeedButton;
    lblTitulo, lblSubTitulo, lblItem, lblCodItem: TLabel;
    FVisible: Boolean;
    FTitleMenuText: string;
    FSubTitleMenuText: string;
    FCodItem: string;
    FItemtext: string;
    FDescrItem: string;
    FTitleFontSize: integer;
    FItemFontSize: integer;
    FSubTitleFontSize: integer;
    FSubItemFontSize: integer;
    FBackgroundColor: Cardinal;
    FTitleFontColor: Cardinal;
    FSubTitleFontColor: Cardinal;
    FItemFontColor: Cardinal;
    FItemBackgroundColor: Cardinal;
{$IFDEF MSWINDOWS}
    ACallBack: TExecutaClickWin;
{$ELSE}
    ACallBack: TExecutaClickMobile;
{$ENDIF}
  public
    constructor Create(Frm: TForm);
    procedure ShowMenu;
    procedure ClickCancel(Sender: TObject);
    procedure HideMenu;
    procedure FinishFade(Sender: TObject);
    procedure ProcessFade(Sender: TObject);
    procedure AddItem(codItem: string; itemText: string);
{$IFDEF MSWINDOWS}
    procedure ItemClick(Sender: TObject);
{$ELSE}
    procedure ItemClick(Sender: TObject; const Point: TPointF);
{$ENDIF}
    property TitleMenuText: string read FTitleMenuText write FTitleMenuText;
    property TitleFontSize: integer read FTitleFontSize write FTitleFontSize;
    property TitleFontColor: Cardinal read FTitleFontColor write FTitleFontColor;
    property SubTitleMenuText: string read FSubTitleMenuText write FSubTitleMenuText;
    property SubTitleFontSize: integer read FSubTitleFontSize write FSubTitleFontSize;
    property SubTitleFontColor: Cardinal read FSubTitleFontColor write FSubTitleFontColor;
    property ItemFontSize: integer read FItemFontSize write FItemFontSize;
    property ItemFontColor: Cardinal read FItemFontColor write FItemFontColor;
    property ItemBackgroundColor: Cardinal read FItemBackgroundColor write FItemBackgroundColor;
    property BackgroundColor: Cardinal read FBackgroundColor write FBackgroundColor;
    property Visible: Boolean read FVisible write FVisible;
    property CodItem: string read FCodItem write FCodItem;
    property DescrItem: string read FDescrItem write FDescrItem;
    property Itemtext: string read FItemText write FItemtext;
{$IFDEF MSWINDOWS}
    property OnClick: TExecutaClickWin read ACallBack write ACallBack;
{$ELSE}
    property OnClick: TExecutaClickMobile read ACallBack write ACallBack;
{$ENDIF}
  end;

implementation

uses View.Menu;

constructor TCustomCombo.Create(Frm: TForm);
begin
  FTitleMenuText := 'Selecione um cliente';
  FTitleFontSize := 18;
  FTitleFontColor := $FF1F2035;

  FSubTitleMenuText := '';
  FSubTitleFontSize := 15;
  FSubTitleFontColor := $FF9E9EB4;

  FItemFontSize := 15;
  FItemFontColor := $FF1F2035;
  FItemBackgroundColor := $FFFFFFFF;

  FBackgroundColor := $FFFFFFFF;

  rectFundo := TRectangle.Create(Frm);
    with rectFundo do
      begin
        Align := TAlignLayout.Contents;
        Fill.Kind := TBrushKind.Solid;
        Fill.Color := FBackgroundColor;
        BringToFront;
        HitTest := false;
        Margins.Right := (Frm.Width + 100) * -1;
        Visible := false;
        Stroke.Kind := TBrushKind.None;
        Padding.Left := 20;
        Padding.Right := 20;
        Tag := 0;
      end;
  Frm.AddObject(rectFundo);

  Ani := TFloatAnimation.Create(rectFundo);
    with Ani do
      begin
        PropertyName := 'Margins.Right';
        StartValue := (Frm.Width + 100) * -1;
        StopValue := 0;
        Inverse := false;
        Duration := 0.3;
        OnFinish := FinishFade;
        OnProcess := ProcessFade;
      end;
  rectFundo.AddObject(Ani);

  lblTitulo := TLabel.Create(rectFundo);
    with lblTitulo do
      begin
        Align := TAlignLayout.MostTop;
        Height := 50;
        VertTextAlign := TTextAlign.Center;
        TextAlign := TTextAlign.Center;
        StyledSettings := StyledSettings - [TStyledSetting.Size, TStyledSetting.FontColor];
        Margins.Top := 0;
        Margins.Bottom := 0;
      end;
  rectFundo.AddObject(lblTitulo);

  lblSubTitulo := TLabel.Create(rectFundo);
    with lblSubTitulo do
      begin
        Align := TAlignLayout.MostTop;
        Height := 20;
        VertTextAlign := TTextAlign.Center;
        TextAlign := TTextAlign.Center;
        StyledSettings := StyledSettings - [TStyledSetting.Size, TStyledSetting.FontColor];
        Margins.Top := 0;
        Margins.Bottom := 0;
      end;

  rectFundo.AddObject(lblSubTitulo);

  vert := TVertScrollBox.Create(rectFundo);

  with vert do
    begin
      Align := TAlignLayout.Client;
      ShowScrollBars := false;
      Margins.Top := 20;
      Margins.Bottom := 20;
      Visible := true;
    end;
  rectFundo.AddObject(vert);

  btnBack := TSpeedButton.Create(rectFundo);
  with btnBack do
    begin
      Width := 48;
      Height := 48;
      Position.X := 13;
      Position.Y := 5;
      BringToFront;
      StyleLookup := 'backtoolbutton';
      Text := '';
      OnClick := ClickCancel;
    end;
  rectFundo.AddObject(btnBack);
end;

procedure TCustomCombo.ClickCancel(Sender: TObject);
begin
  FCodItem := '';
  FDescrItem := '';
  HideMenu;
end;

{$IFDEF MSWINDOWS}

procedure TCustomCombo.ItemClick(Sender: TObject);
begin

 { if Assigned(Sender) and (Sender is TLabel) then
  begin
    FCodItem := TLabel(Sender).TagString;
    FItemtext := TLabel(Sender).Text;
    FDescrItem := TLabel(Sender).Text;
    ACallBack(Sender);
  end;      }

  FCodItem := TLabel(Sender).TagString;
  frmMenu.edtCodigoCliente.Text := FCodItem;
  HideMenu;

end;

{$ELSE}

procedure TCustomCombo.ItemClick(Sender: TObject; const Point: TPointF);
begin
{if Assigned(Sender) and (Sender is TLabel) then
  begin
    FCodItem := TLabel(Sender).TagString;
    FItemtext := TLabel(Sender).Text;
    FDescrItem := TLabel(Sender).Text;
    ACallBack(Sender);
  end;}

  FCodItem := TLabel(Sender).TagString;
  frmMenu.edtCodigoCliente.Text := FCodItem;
  HideMenu;
end;
{$ENDIF}

procedure TCustomCombo.ShowMenu;
begin
  vert.ViewportPosition := TPointF.Zero;

  rectFundo.Visible := true;
  FVisible := true;
  rectFundo.Fill.Color := FBackgroundColor;

  Ani.Inverse := false;
  Ani.Start;

  if Trim(FTitleMenuText) = '' then
    lblTitulo.Height := 0
  else
  begin
    lblTitulo.Height := 50;
    lblTitulo.Margins.Top := 50;
    lblTitulo.Margins.Bottom := 10;
  end;

  lblTitulo.Text := FTitleMenuText;

  if Trim(FSubTitleMenuText) = '' then
    lblSubTitulo.Height := 0
  else
  begin
    lblSubTitulo.Height := 20;

    if lblTitulo.Height > 0 then
      lblSubTitulo.Margins.Top := 10
    else
      lblSubTitulo.Margins.Top := 50;

    lblSubTitulo.Margins.Bottom := 10;
  end;

  lblSubTitulo.Text := FSubTitleMenuText;

end;

procedure TCustomCombo.AddItem(codItem: string; itemText: string);
begin
  rectItem := TRectangle.Create(vert);
  with rectItem do
  begin
    Align := TAlignLayout.MostTop;
    Fill.Kind := TBrushKind.Solid;
    Fill.Color := FItemBackgroundColor;
    HitTest := true;
    XRadius := 6; {valor de arredondamento de bordas X}
    YRadius := 6; {valor de arredondamento de bordas Y}
    Margins.Bottom := 10; {margem para o próximo rect abaixo}
    Height := 25; {tamanho do rect}
    Stroke.Kind := TBrushKind.None;
  end;
  vert.AddObject(rectItem);

  lblItem := TLabel.Create(rectItem);
  with lblItem do
  begin
    Text := itemText;
    Align := TAlignLayout.Client;
    VertTextAlign := TTextAlign.Center;
    TextAlign := TTextAlign.Leading;
    StyledSettings := StyledSettings - [TStyledSetting.Size, TStyledSetting.FontColor];
    HitTest := true;
    Margins.Left := 10;
    Margins.Right := 10;
    TagString := codItem;

  lblCodItem := TLabel.Create(rectItem);
  with lblCodItem do
  begin
    Text := codItem;
    Align := TAlignLayout.MostLeft;
    VertTextAlign := TTextAlign.Center;
    TextAlign := TTextAlign.Leading;
    StyledSettings := StyledSettings - [TStyledSetting.Size, TStyledSetting.FontColor];
    HitTest := true;
    Width := 40;
  end;

  rectItem.AddObject(lblCodItem);


{$IFDEF MSWINDOWS}
    OnClick := ItemClick;
{$ELSE}
    OnTap := ItemClick;
{$ENDIF}

  end;

  rectItem.AddObject(lblItem);

  vert.Repaint;
end;

procedure TCustomCombo.FinishFade(Sender: TObject);
begin
  rectFundo.Visible := FVisible;
end;

procedure TCustomCombo.ProcessFade(Sender: TObject);
begin
  rectFundo.Margins.Left := rectFundo.Margins.Right * -1;
end;

procedure TCustomCombo.HideMenu;
begin
  FVisible := false;
  Ani.Delay := 0;
  Ani.Inverse := true;
  Ani.Start;
end;

end.