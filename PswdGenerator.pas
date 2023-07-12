unit Model.PswdGenerator;

interface

uses
  SysUtils;

type
  TForce = (Weak, Medium, Strong);

function GenPassword(Tamanho: Integer; Forca: TForce): string;

implementation

const
  CharsWeak = 'abcdefghijklmnopqrstuvwxyz0123456789';
  CharsMedium = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  CharsStrong = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*()_+-=';

function GenPassword(Tamanho: Integer; Forca: TForce): string;
var
  i: Integer;
  Chars: string;
begin
  case Forca of
    Weak: Chars := CharsWeak;
    Medium: Chars := CharsMedium;
    Strong: Chars := CharsStrong;
  end;

  Result := '';
  for i := 1 to Tamanho do
    Result := Result + Chars[Random(Length(Chars)) + 1];
end;

end.