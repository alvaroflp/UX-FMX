unit Model.ToastMessage;

interface

uses
  System.SysUtils,
  System.UITypes,
  System.Classes,
  System.DateUtils,
  FMX.Ani,
  FMX.Types,
  FMX.Forms,
  FMX.Layouts,
  FMX.Objects;

type
  TToastPosition = (tpTop, tpBottom);

  TToastMessage = class
  private

  public
    class procedure Show(Const Text: String; Second: Integer = 3;
      Height: Integer = 40; Position: TToastPosition = TToastPosition.tpTop);

  protected

  published

  end;

implementation

var
  LyContainer: TLayout;
  LyBorder: TRoundRect;
  FlAnimation: TFloatAnimation;
  TxMessage: TText;

  { TToastMessage }

  { TTostMessage }

class procedure TToastMessage.Show(const Text: String; Second, Height: Integer;
  Position: TToastPosition);
const
  TextCollor: TAlphaColor = TAlphaColorRec.White;
  BalloonCollor: TAlphaColor = TAlphaColorRec.Black;
var
  TimeNow, TimeFinish: TTime;
  Thr: TThread;
begin

  if Screen.ActiveForm <> nil then
  begin

    // Oculta os controles existentes, se houver
    if Assigned(LyBorder) then
      LyBorder.Visible := False;

    if Assigned(LyContainer) then
      LyContainer.Visible := False;

    // Cria a notificação
    if not Assigned(LyContainer) then
    begin
      LyContainer := TLayout.Create(Screen.ActiveForm);
      LyContainer.Parent := Screen.ActiveForm;
      LyContainer.Width := Screen.ActiveForm.ClientWidth;
      LyContainer.Tag := 0; // 0 = Abrindo nova mensagem | 1 = Ainda em execução
    end;

    LyContainer.Height := Height;

    if Position = TToastPosition.tpTop then
      LyContainer.Position.Y := 5
    else if Position = TToastPosition.tpBottom then
      LyContainer.Position.Y := Screen.ActiveForm.ClientHeight -
        LyContainer.Height - 20;

    LyContainer.Visible := True;

    if not Assigned(LyBorder) then
    begin
      LyBorder := TRoundRect.Create(LyContainer);
      LyBorder.Parent := LyContainer;
      LyBorder.Align := TAlignLayout.Center;
      LyBorder.Stroke.Thickness := 2;
      LyBorder.Stroke.Color := TAlphaColorRec.White;
      LyBorder.Fill.Color := BalloonCollor;
      LyBorder.Height := LyContainer.Height;
      LyBorder.Visible := True;
    end;

    if not Assigned(FlAnimation) then
    begin
      FlAnimation := TFloatAnimation.Create(LyBorder);
      FlAnimation.Enabled := False;
      FlAnimation.Inverse := False;
      FlAnimation.Parent := LyBorder;
      FlAnimation.AnimationType := TAnimationType.InOut;
      FlAnimation.Interpolation := TInterpolationType.Exponential;
      FlAnimation.PropertyName := 'Width';
      FlAnimation.Duration := 0.5;
      FlAnimation.StartValue := 40;
      FlAnimation.StopValue := LyContainer.Width - 10;
      FlAnimation.Start;
    end;

    if not Assigned(TxMessage) then
    begin
      TxMessage := TText.Create(LyBorder);
      TxMessage.Parent := LyBorder;
      TxMessage.Align := TAlignLayout.Client;
      TxMessage.TextSettings.FontColor := TextCollor;
      TxMessage.TextSettings.Font.Size := 14;
      TxMessage.TextSettings.Font.Style := [];
      TxMessage.TextSettings.WordWrap := True;
    end;

    TxMessage.Visible := False;
    TxMessage.Text := Text;

    Thr := TThread.CreateAnonymousThread(
      procedure
      begin
        Sleep(300);
        TThread.Synchronize(nil,
          procedure
          begin
            TxMessage.Visible := True;
          end);

        TimeNow := Now;
        TimeFinish := TimeNow;
        TimeFinish := IncSecond(TimeFinish, Second);
        LyContainer.Tag := 1;

        while (TimeFinish >= TimeNow) and (LyContainer.Tag = 1) do
        begin
          Sleep(100);
          TimeNow := Now;
        end;

        if LyContainer.Tag = 1 then
        // Só finaliza o componente se não foi sobreposto por outra mensagem
        begin
          TThread.Synchronize(nil,
            procedure
            begin
              FlAnimation.Inverse := True;
              FlAnimation.Start;
              TxMessage.Visible := False;
            end);

          Sleep(350);
          TThread.Synchronize(nil,
            procedure
            begin
              LyContainer.Visible := False;
            end);
        end;
      end);

    Thr.FreeOnTerminate := True;
    Thr.Start;
  end
  else
    raise Exception.Create
      ('Desculpe, não foi possível exibir a notificação pois não existe nenhum formulário acessível no momento.');
end;

end.