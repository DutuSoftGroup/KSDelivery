{*******************************************************************************
  作者: fendou116688@163.com 2016/8/7
  描述: 门岗读卡器维护记录
*******************************************************************************}
unit UFrameHYReaders;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData,
  cxContainer, dxLayoutControl, cxMaskEdit, cxButtonEdit, cxTextEdit,
  ADODB, cxLabel, UBitmapPanel, cxSplitter, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin, Menus;

type
  TfFrameHYReaders = class(TfFrameNormal)
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditName: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    IP1: TMenuItem;
    N3: TMenuItem;
    procedure EditNamePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
  private
    { Private declarations }
  protected
    function InitFormDataSQL(const nWhere: string): string; override;
    {*查询SQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysConst, USysBusiness, USysDB, UDataModule,
  UFormBase, UFormWait, ShellAPI;

class function TfFrameHYReaders.FrameID: integer;
begin
  Result := cFI_FrameHYReaders;
end;

function TfFrameHYReaders.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select * From ' + sTable_HYReader;
  if nWhere <> '' then
    Result := Result + ' Where (' + nWhere + ')';;
end;

//Desc: 添加
procedure TfFrameHYReaders.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormHYReaders, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: 修改
procedure TfFrameHYReaders.BtnEditClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nP.FCommand := cCmd_EditData;
    nP.FParamA := SQLQuery.FieldByName('R_ID').AsString;
    CreateBaseFormItem(cFI_FormHYReaders, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
    begin
      InitFormData(FWhere);
    end;
  end;
end;

//Desc: 删除
procedure TfFrameHYReaders.BtnDelClick(Sender: TObject);
var nStr: String;
begin
  nStr := 'Delete From %s Where R_ID=%s';
  nStr := Format(nStr, [sTable_HYReader, SQLQuery.FieldByName('R_ID').AsString]);
  FDM.ExecuteSQL(nStr);
end;

//Desc: 查询
procedure TfFrameHYReaders.EditNamePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;

    FWhere := Format('H_Name Like ''%%%s%%''', [EditName.Text]);
    InitFormData(FWhere);
  end;
end;

//读卡器抓拍
procedure TfFrameHYReaders.N1Click(Sender: TObject);
begin
  inherited;
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    CapturePicture(SQLQuery.FieldByName('H_ID').AsString,
      SQLQuery.FieldByName('H_ID').AsString);
  end;
end;

procedure TfFrameHYReaders.N2Click(Sender: TObject);
var nID: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要查看的记录', sHint);
    Exit;
  end;

  nID := SQLQuery.FieldByName('H_ID').AsString;
  ShowCapturePicture(nID);
end;

procedure TfFrameHYReaders.N3Click(Sender: TObject);
begin
  inherited;
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要抬杆的读卡器', sHint);
    Exit;
  end;

  HYReaderOpenDoor(SQLQuery.FieldByName('H_ID').AsString);
end;

initialization
  gControlManager.RegCtrl(TfFrameHYReaders, TfFrameHYReaders.FrameID);
end.
