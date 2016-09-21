{*******************************************************************************
  ����: dmzn@163.com 2014-11-25
  ����: ������������
*******************************************************************************}
unit UFrameTrucks;

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
  TfFrameTrucks = class(TfFrameNormal)
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
    N4: TMenuItem;
    N5: TMenuItem;
    N7: TMenuItem;
    procedure EditNamePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure PMenu1Popup(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
  private
    { Private declarations }
  protected
    function InitFormDataSQL(const nWhere: string): string; override;
    {*��ѯSQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysConst, USysBusiness, USysDB, UDataModule,
  UFormBase, UFormWait, ShellAPI;

class function TfFrameTrucks.FrameID: integer;
begin
  Result := cFI_FrameTrucks;
end;

function TfFrameTrucks.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select * From ' + sTable_Truck;
  if nWhere <> '' then
    Result := Result + ' Where (' + nWhere + ')';
  Result := Result + ' Order By T_PY';
end;

//Desc: ���
procedure TfFrameTrucks.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormTrucks, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: �޸�
procedure TfFrameTrucks.BtnEditClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nP.FCommand := cCmd_EditData;
    nP.FParamA := SQLQuery.FieldByName('R_ID').AsString;
    CreateBaseFormItem(cFI_FormTrucks, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
    begin
      InitFormData(FWhere);
    end;
  end;
end;

//Desc: ɾ��
procedure TfFrameTrucks.BtnDelClick(Sender: TObject);
var nStr,nTruck,nEvent: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nTruck := SQLQuery.FieldByName('T_Truck').AsString;
    nStr   := Format('ȷ��Ҫɾ������[ %s ]��?', [nTruck]);
    if not QueryDlg(nStr, sAsk) then Exit;

    nStr := 'Delete From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_Truck, SQLQuery.FieldByName('R_ID').AsString]);

    FDM.ExecuteSQL(nStr);

    nEvent := 'ɾ��[ %s ]������Ϣ.';
    nEvent := Format(nEvent, [nTruck]);
    FDM.WriteSysLog(sFlag_CommonItem, nTruck, nEvent);

    InitFormData(FWhere);
  end;
end;

procedure TfFrameTrucks.PMenu1Popup(Sender: TObject);
begin
  N4.Enabled := BtnAdd.Enabled;
  N5.Enabled := BtnAdd.Enabled;
  N7.Enabled := BtnAdd.Enabled;
end;

//Desc: ��ѯ
procedure TfFrameTrucks.EditNamePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;

    FWhere := Format('T_Truck Like ''%%%s%%''', [EditName.Text]);
    InitFormData(FWhere);
  end;
end;

//������ӱ�ǩ
procedure TfFrameTrucks.N4Click(Sender: TObject);
var nStr, nRFIDCard, nFlag: string;
begin
  if not BtnAdd.Enabled then Exit;

  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('T_Truck').AsString;
    nRFIDCard := SQLQuery.FieldByName('T_Card').AsString;
    nFlag := SQLQuery.FieldByName('T_CardUse').AsString;
    
    if SetTruckRFIDCard(nStr, nRFIDCard, nFlag, nRFIDCard) then
    begin
      nStr := 'Update %s Set T_Card=null,T_CardUse=''%s''  Where T_Card=''%s''';
      nStr := Format(nStr, [sTable_Truck, {nRFIDCard,} nFlag,
        nRFIDCard]);
      //xxxxxx

      FDM.ExecuteSQL(nStr);//���Ѿ��󶨸ñ�ǩ�ĵ���ǩ���

      nStr := 'Update %s Set T_Card=''%s'',T_CardUse=''%s''  Where R_ID=%s';
      nStr := Format(nStr, [sTable_Truck, nRFIDCard, nFlag,
        SQLQuery.FieldByName('R_ID').AsString]);
      //xxxxxx

      FDM.ExecuteSQL(nStr);
      InitFormData(FWhere);
      ShowMsg('������ӱ�ǩ�ɹ�', sHint);
    end;
  end;
end;


//���õ��ӱ�ǩ
procedure TfFrameTrucks.N5Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := 'Update %s Set T_CardUse=''%s'' Where R_ID=%s';
    nStr := Format(nStr, [sTable_Truck, sFlag_Yes,
      SQLQuery.FieldByName('R_ID').AsString]);
    //xxxxxx

    FDM.ExecuteSQL(nStr);
    InitFormData(FWhere);
    ShowMsg('���õ��ӱ�ǩ�ɹ�', sHint);
  end;
end;

procedure TfFrameTrucks.N7Click(Sender: TObject);
var nStr: string;
begin
  if not BtnAdd.Enabled then Exit;

  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := 'Update %s Set T_CardUse=''%s'' Where R_ID=%s';
    nStr := Format(nStr, [sTable_Truck, sFlag_No,
      SQLQuery.FieldByName('R_ID').AsString]);
    //xxxxxx

    FDM.ExecuteSQL(nStr);
    InitFormData(FWhere);
    ShowMsg('ͣ�õ��ӱ�ǩ�ɹ�', sHint);
  end;
end;


procedure TfFrameTrucks.N1Click(Sender: TObject);
begin
  inherited;
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    CapturePicture('FH001', SQLQuery.FieldByName('T_Truck').AsString);
  end;
end;

procedure TfFrameTrucks.N2Click(Sender: TObject);
var nID: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ�鿴�ļ�¼', sHint);
    Exit;
  end;

  nID := SQLQuery.FieldByName('T_Truck').AsString;
  ShowCapturePicture(nID);
end;

initialization
  gControlManager.RegCtrl(TfFrameTrucks, TfFrameTrucks.FrameID);
end.
