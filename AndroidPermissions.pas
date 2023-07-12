unit Model.AndroidPermissions;

interface

uses 
  FMX.DialogService, 
  FMX.MediaLibrary.Actions,
{$IFDEF ANDROID}
  Androidapi.Helpers, 
  Androidapi.JNI.JavaTypes, 
  Androidapi.JNI.Os,
{$ENDIF}
  System.Permissions;

type
  TCallbackProc = procedure(Sender: TObject) of Object;

  TAndroidPermissions = class
  private
    CurrentRequest: string;
    pCamera, pReadStorage, pWriteStorage: string; // Camera / Library
    pFineLocation, pCoarseLocation: string; // GPS
    pPhoneState: string; // Phone State

    procedure PermissionRequestResult(Sender: TObject;
      const APermissions: TArray<string>;
      const AGrantResults: TArray<TPermissionStatus>);
  public
    MyCallBack, MyCallBackError: TCallbackProc;
    MyCameraAction: TTakePhotoFromCameraAction;
    MyLibraryAction: TTakePhotoFromLibraryAction;

    constructor Create;
    function VerifyCameraAccess(): boolean;
    procedure Camera(ActionPhoto: TTakePhotoFromCameraAction;
      ACallBackError: TCallbackProc = nil);
    procedure PhotoLibrary(ActionLibrary: TTakePhotoFromLibraryAction;
      ACallBackError: TCallbackProc = nil);
    procedure Location(ACallBack: TCallbackProc = nil;
      ACallBackError: TCallbackProc = nil);
    procedure PhoneState(ACallBack: TCallbackProc = nil;
      ACallBackError: TCallbackProc = nil);
  published
    // property CameraGranted: boolean read FCameraGranted write FCameraGranted;
  end;

implementation

function TAndroidPermissions.VerifyCameraAccess(): boolean;
begin
  Result := false;

{$IFDEF ANDROID}
  Result := PermissionsService.IsEveryPermissionGranted
    ([pCamera, pReadStorage, pWriteStorage]);
{$ENDIF}
end;

constructor TAndroidPermissions.Create();
begin
{$IFDEF ANDROID}
  pCamera := JStringToString(TJManifest_permission.JavaClass.Camera);
  pReadStorage := JStringToString
    (TJManifest_permission.JavaClass.READ_EXTERNAL_STORAGE);
  pWriteStorage := JStringToString
    (TJManifest_permission.JavaClass.WRITE_EXTERNAL_STORAGE);
  pCoarseLocation := JStringToString
    (TJManifest_permission.JavaClass.ACCESS_COARSE_LOCATION);
  pFineLocation := JStringToString
    (TJManifest_permission.JavaClass.ACCESS_FINE_LOCATION);
  pPhoneState := JStringToString
    (TJManifest_permission.JavaClass.READ_PHONE_STATE);
{$ENDIF}
end;

procedure TAndroidPermissions.PermissionRequestResult(Sender: TObject;
  const APermissions: TArray<string>;
  const AGrantResults: TArray<TPermissionStatus>);
var
  ret: boolean;
begin
  ret := false;

  // CAMERA (CAMERA + READ_EXTERNAL_STORAGE + WRITE_EXTERNAL_STORAGE)
  if CurrentRequest = 'CAMERA' then
  begin
    if (Length(AGrantResults) = 3) and
      (AGrantResults[0] = TPermissionStatus.Granted) and
      (AGrantResults[1] = TPermissionStatus.Granted) and
      (AGrantResults[2] = TPermissionStatus.Granted) then
    begin
      ret := true;

      if Assigned(MyCameraAction) then
        MyCameraAction.Execute;
    end;
  end;

  // LIBRARY (READ_EXTERNAL_STORAGE + WRITE_EXTERNAL_STORAGE)
  if CurrentRequest = 'LIBRARY' then
  begin
    if (Length(AGrantResults) = 2) and
      (AGrantResults[0] = TPermissionStatus.Granted) and
      (AGrantResults[1] = TPermissionStatus.Granted) then
    begin
      ret := true;

      if Assigned(MyLibraryAction) then
        MyLibraryAction.Execute;
    end;
  end;

  // LOCATION (ACCESS_COARSE_LOCATION + ACCESS_FINE_LOCATION)
  if CurrentRequest = 'LOCATION' then
  begin
    if (Length(AGrantResults) = 2) and
      (AGrantResults[0] = TPermissionStatus.Granted) and
      (AGrantResults[1] = TPermissionStatus.Granted) then
    begin
      ret := true;

      if Assigned(MyCallBack) then
        MyCallBack(Self);
    end;
  end;

  // PHONE STATE
  if CurrentRequest = 'READ_PHONE_STATE' then
  begin
    if (Length(AGrantResults) = 1) and
      (AGrantResults[0] = TPermissionStatus.Granted) then
    begin
      ret := true;

      if Assigned(MyCallBack) then
        MyCallBack(Self);
    end;
  end;

  if NOT ret then
  begin
    if Assigned(MyCallBackError) then
      MyCallBackError(Self);
  end;
end;

procedure TAndroidPermissions.Camera(ActionPhoto: TTakePhotoFromCameraAction;
  ACallBackError: TCallbackProc = nil);
begin
  MyCameraAction := ActionPhoto;
  MyCallBackError := ACallBackError;
  CurrentRequest := 'CAMERA';

{$IFDEF ANDROID}
  PermissionsService.RequestPermissions([pCamera, pReadStorage, pWriteStorage],
    PermissionRequestResult);
{$ENDIF}
{$IFDEF IOS}
  MyCameraAction.Execute;
{$ENDIF}
{$IFDEF MSWINDOWS}
  TDialogService.ShowMessage('Nao suportado no Windows');
{$ENDIF}
end;

procedure TAndroidPermissions.PhotoLibrary(ActionLibrary
  : TTakePhotoFromLibraryAction; ACallBackError: TCallbackProc = nil);
begin
  MyLibraryAction := ActionLibrary;
  MyCallBackError := ACallBackError;
  CurrentRequest := 'LIBRARY';

{$IFDEF ANDROID}
  PermissionsService.RequestPermissions([pReadStorage, pWriteStorage],
    PermissionRequestResult);
{$ENDIF}
{$IFDEF IOS}
  ActionLibrary.Execute;
{$ENDIF}
{$IFDEF MSWINDOWS}
  TDialogService.ShowMessage('Nao suportado no Windows');
{$ENDIF}
end;

procedure TAndroidPermissions.Location(ACallBack: TCallbackProc = nil;
  ACallBackError: TCallbackProc = nil);
begin
  MyCallBack := ACallBack;
  MyCallBackError := ACallBackError;
  CurrentRequest := 'LOCATION';

{$IFDEF ANDROID}
  PermissionsService.RequestPermissions([pCoarseLocation, pFineLocation],
    PermissionRequestResult);
{$ENDIF}
{$IFDEF IOS}
  if Assigned(MyCallBack) then
    ACallBack(Self);
{$ENDIF}
{$IFDEF MSWINDOWS}
  TDialogService.ShowMessage('Nao suportado no Windows');
{$ENDIF}
end;

procedure TAndroidPermissions.PhoneState(ACallBack: TCallbackProc = nil;
  ACallBackError: TCallbackProc = nil);
begin
  MyCallBack := ACallBack;
  MyCallBackError := ACallBackError;
  CurrentRequest := 'READ_PHONE_STATE';

{$IFDEF ANDROID}
  PermissionsService.RequestPermissions([pPhoneState], PermissionRequestResult);
{$ENDIF}
{$IFDEF IOS}
  if Assigned(MyCallBack) then
    ACallBack(Self);
{$ENDIF}
{$IFDEF MSWINDOWS}
  TDialogService.ShowMessage('Nao suportado no Windows');
{$ENDIF}
end;

end.