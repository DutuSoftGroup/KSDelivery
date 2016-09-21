{*******************************************************************************
  ����: dmzn@163.com 2008-08-07
  ����: ϵͳ���ݿⳣ������

  ��ע:
  *.�Զ�����SQL���,֧�ֱ���:$Inc,����;$Float,����;$Integer=sFlag_Integer;
    $Decimal=sFlag_Decimal;$Image,��������
*******************************************************************************}
unit USysDB;

{$I Link.inc}
interface

uses
  SysUtils, Classes;

const
  cSysDatabaseName: array[0..4] of String = (
     'Access', 'SQL', 'MySQL', 'Oracle', 'DB2');
  //db names

type
  TSysDatabaseType = (dtAccess, dtSQLServer, dtMySQL, dtOracle, dtDB2);
  //db types

  PSysTableItem = ^TSysTableItem;
  TSysTableItem = record
    FTable: string;
    FNewSQL: string;
  end;
  //ϵͳ����

var
  gSysTableList: TList = nil;                        //ϵͳ������
  gSysDBType: TSysDatabaseType = dtSQLServer;        //ϵͳ��������

//------------------------------------------------------------------------------
const
  //�����ֶ�
  sField_Access_AutoInc          = 'Counter';
  sField_SQLServer_AutoInc       = 'Integer IDENTITY (1,1) PRIMARY KEY';

  //С���ֶ�
  sField_Access_Decimal          = 'Float';
  sField_SQLServer_Decimal       = 'Decimal(15, 5)';

  //ͼƬ�ֶ�
  sField_Access_Image            = 'OLEObject';
  sField_SQLServer_Image         = 'Image';

  //�������
  sField_SQLServer_Now           = 'getDate()';

ResourceString     
  {*Ȩ����*}
  sPopedom_Read       = 'A';                         //���
  sPopedom_Add        = 'B';                         //���
  sPopedom_Edit       = 'C';                         //�޸�
  sPopedom_Delete     = 'D';                         //ɾ��
  sPopedom_Preview    = 'E';                         //Ԥ��
  sPopedom_Print      = 'F';                         //��ӡ
  sPopedom_Export     = 'G';                         //����

  {*��ر��*}
  sFlag_Yes           = 'Y';                         //��
  sFlag_No            = 'N';                         //��
  sFlag_Unknow        = 'U';                         //δ֪        
  sFlag_Enabled       = 'Y';                         //����
  sFlag_Disabled      = 'N';                         //����

  sFlag_Integer       = 'I';                         //����
  sFlag_Decimal       = 'D';                         //С��

  sFlag_TypeVIP       = 'V';
  sFlag_TypeCommon    = 'C';

  sFlag_NotMatter     = '@';                         //�޹ر��(�����Ŷ���)
  sFlag_ForceDone     = '#';                         //ǿ�����(δ���ǰ����)
  sFlag_FixedNo       = '$';                         //ָ�����(ʹ����ͬ���)

  sFlag_ForceHint     = 'Bus_HintMsg';               //ǿ����ʾ

  sFlag_SerailSYS     = 'SYSTableID';                //SYS������
  sFlag_TruckLog      = 'SYS_TruckLog';              //������¼
  sFlag_PoundLog      = 'SYS_PoundLog';              //������¼

  sFlag_SysParam      = 'SysParam';                  //ϵͳ����
  sFlag_Company       = 'Company';                   //��˾��
  sFlag_ValidDate     = 'SysValidDate';              //��Ч��
  sFlag_JBTime        = 'JiaoBanTime';               //����ʱ��
  sFlag_JBParam       = 'JiaoBanParam';              //�������
  sFlag_AutoIn        = 'Truck_AutoIn';              //�Զ�����
  sFlag_AutoOut       = 'Truck_AutoOut';             //�Զ�����
  sFlag_EnableBakdb   = 'Uses_BackDB';               //���ÿ�
  sFlag_CusType       = 'CustomerType';              //�ͻ�����
  sFlag_SAPSrvURL     = 'SAPServiceURL';
  sFlag_MITSrvURL     = 'MITServiceURL';
  sFlag_HardSrvURL    = 'HardMonURL';

  sFlag_CommonItem    = 'CommonItem';                //������Ϣ
  sFlag_SaveKeepTime  = 'SaveKeepTime';              //�����¼���

  sFlag_ProviderItem  = 'ProviderItem';              //��Ӧ����Ϣ��
  sFlag_CustomerItem  = 'CustomerItem';              //�ͻ���Ϣ��

  {*���ݱ�*}
  sTable_Group        = 'Sys_Group';                 //�û���
  sTable_User         = 'Sys_User';                  //�û���
  sTable_Menu         = 'Sys_Menu';                  //�˵���
  sTable_Popedom      = 'Sys_Popedom';               //Ȩ�ޱ�
  sTable_PopItem      = 'Sys_PopItem';               //Ȩ����
  sTable_Entity       = 'Sys_Entity';                //�ֵ�ʵ��
  sTable_DictItem     = 'Sys_DataDict';              //�ֵ���ϸ

  sTable_SysDict      = 'Sys_Dict';                  //ϵͳ�ֵ�
  sTable_ExtInfo      = 'Sys_ExtInfo';               //������Ϣ
  sTable_SysLog       = 'Sys_EventLog';              //ϵͳ��־
  sTable_BaseInfo     = 'Sys_BaseInfo';              //������Ϣ
  sTable_SerialBase   = 'Sys_SerialBase';            //��������
  sTable_SerialStatus = 'Sys_SerialStatus';          //���״̬

  sTable_Card         = 'S_Card';                    //���۴ſ�
  sTable_Truck        = 'S_Truck';                   //������
  sTable_TruckLog     = 'S_TruckLog';                //������־
  sTable_HYReader     = 'S_HYReader';                //������־

  sTable_Provider     = 'P_Provider';                //�ͻ���

  sTable_PoundLog     = 'S_PoundLog';                //��������
  sTable_PoundBak     = 'S_PoundBak';                //��������
  sTable_Picture      = 'Sys_Picture';               //���ͼƬ

  {*�½���*} 
  sSQL_NewSysDict = 'Create Table $Table(D_ID $Inc, D_Name varChar(15),' +
       'D_Desc varChar(30), D_Value varChar(50), D_Memo varChar(20),' +
       'D_ParamA $Float, D_ParamB varChar(50), D_Index Integer Default 0)';
  {-----------------------------------------------------------------------------
   ϵͳ�ֵ�: SysDict
   *.D_ID: ���
   *.D_Name: ����
   *.D_Desc: ����
   *.D_Value: ȡֵ
   *.D_Memo: �����Ϣ
   *.D_ParamA: �������
   *.D_ParamB: �ַ�����
   *.D_Index: ��ʾ����
  -----------------------------------------------------------------------------}

  sSQL_NewExtInfo = 'Create Table $Table(I_ID $Inc, I_Group varChar(20),' +
       'I_ItemID varChar(20), I_Item varChar(30), I_Info varChar(500),' +
       'I_ParamA $Float, I_ParamB varChar(50), I_Index Integer Default 0)';
  {-----------------------------------------------------------------------------
   ��չ��Ϣ��: ExtInfo
   *.I_ID: ���
   *.I_Group: ��Ϣ����
   *.I_ItemID: ��Ϣ��ʶ
   *.I_Item: ��Ϣ��
   *.I_Info: ��Ϣ����
   *.I_ParamA: �������
   *.I_ParamB: �ַ�����
   *.I_Memo: ��ע��Ϣ
   *.I_Index: ��ʾ����
  -----------------------------------------------------------------------------}
  
  sSQL_NewSysLog = 'Create Table $Table(L_ID $Inc, L_Date DateTime,' +
       'L_Man varChar(32),L_Group varChar(20), L_ItemID varChar(20),' +
       'L_KeyID varChar(20), L_Event varChar(220))';
  {-----------------------------------------------------------------------------
   ϵͳ��־: SysLog
   *.L_ID: ���
   *.L_Date: ��������
   *.L_Man: ������
   *.L_Group: ��Ϣ����
   *.L_ItemID: ��Ϣ��ʶ
   *.L_KeyID: ������ʶ
   *.L_Event: �¼�
  -----------------------------------------------------------------------------}

  sSQL_NewBaseInfo = 'Create Table $Table(B_ID $Inc, B_Group varChar(15),' +
       'B_Text varChar(100), B_Py varChar(25), B_Memo varChar(50),' +
       'B_PID Integer, B_Index Float)';
  {-----------------------------------------------------------------------------
   ������Ϣ��: BaseInfo
   *.B_ID: ���
   *.B_Group: ����
   *.B_������Text: ����
   *.B_Py: ƴ����д
   *.B_Memo: ��ע��Ϣ
   *.B_PID: �ϼ��ڵ�
   *.B_Index: ����˳��
  -----------------------------------------------------------------------------}

  sSQL_NewSerialBase = 'Create Table $Table(R_ID $Inc, B_Group varChar(15),' +
       'B_Object varChar(32), B_Prefix varChar(25), B_IDLen Integer,' +
       'B_Base Integer, B_Date DateTime)';
  {-----------------------------------------------------------------------------
   ���б�Ż�����: SerialBase
   *.R_ID: ���
   *.B_Group: ����
   *.B_Object: ����
   *.B_Prefix: ǰ׺
   *.B_IDLen: ��ų�
   *.B_Base: ����
   *.B_Date: �ο�����
  -----------------------------------------------------------------------------}

  sSQL_NewSerialStatus = 'Create Table $Table(R_ID $Inc, S_Object varChar(32),' +
       'S_SerailID varChar(32), S_PairID varChar(32), S_Status Char(1),' +
       'S_Date DateTime)';
  {-----------------------------------------------------------------------------
   ����״̬��: SerialStatus
   *.R_ID: ���
   *.S_Object: ����
   *.S_SerailID: ���б��
   *.S_PairID: ��Ա��
   *.S_Status: ״̬(Y,N)
   *.S_Date: ����ʱ��
  -----------------------------------------------------------------------------}

  sSQL_NewCard = 'Create Table $Table(R_ID $Inc, C_Card varChar(16),' +
       'C_Card2 varChar(32), C_Card3 varChar(32),' +
       'C_Owner varChar(15), C_TruckNo varChar(15), C_Status Char(1),' +
       'C_Freeze Char(1), C_Used Char(1), C_UseTime Integer Default 0,' +
       'C_Man varChar(32), C_Date DateTime, C_Memo varChar(500))';
  {-----------------------------------------------------------------------------
   �ſ���:Card
   *.R_ID:��¼���
   *.C_Card:������
   *.C_Card2,C_Card3:������
   *.C_Owner:�����˱�ʶ
   *.C_TruckNo:�������
   *.C_Used:��;(��Ӧ,����)
   *.C_UseTime:ʹ�ô���
   *.C_Status:״̬(����,ʹ��,ע��,��ʧ)
   *.C_Freeze:�Ƿ񶳽�
   *.C_Man:������
   *.C_Date:����ʱ��
   *.C_Memo:��ע��Ϣ
  -----------------------------------------------------------------------------}

    sSQL_NewTruck = 'Create Table $Table(R_ID $Inc, T_Truck varChar(15), ' +
       'T_PY varChar(15), T_Owner varChar(32), T_Phone varChar(15), T_Used Char(1), ' +
       'T_PrePValue $Float, T_PrePMan varChar(32), T_PrePTime DateTime, ' +
       'T_PrePUse Char(1), T_MinPVal $Float, T_MaxPVal $Float, ' +
       'T_PValue $Float Default 0, T_PTime Integer Default 0,' +
       'T_PlateColor varChar(12),T_Type varChar(12), T_LastTime DateTime, ' +
       'T_Card varChar(32), T_CardUse Char(1), T_NoVerify Char(1),' +
       'T_Valid Char(1), T_VIPTruck Char(1), T_HasGPS Char(1),' +
       'T_StartTime DateTime, T_EndTime DateTime, ' + 
       'T_MatePID varChar(15), T_MateID varChar(15), T_MateName varChar(80),' +
       'T_SrcAddr varChar(150), T_DestAddr varChar(150)' +
       ')';
  {-----------------------------------------------------------------------------
   ������Ϣ:Truck
   *.R_ID: ��¼��
   *.T_Truck: ���ƺ�
   *.T_PY: ����ƴ��
   *.T_Owner: ����
   *.T_Phone: ��ϵ��ʽ
   *.T_Used: ��;(��Ӧ,����)
   *.T_PrePValue: Ԥ��Ƥ��
   *.T_PrePMan: Ԥ��˾��
   *.T_PrePTime: Ԥ��ʱ��
   *.T_PrePUse: ʹ��Ԥ��
   *.T_MinPVal: ��ʷ��СƤ��
   *.T_MaxPVal: ��ʷ���Ƥ��
   *.T_PValue: ��ЧƤ��
   *.T_PTime: ��Ƥ����
   *.T_PlateColor: ������ɫ
   *.T_Type: ����
   *.T_LastTime: �ϴλ
   *.T_Card: ���ӱ�ǩ
   *.T_CardUse: ʹ�õ���ǩ(Y/N)
   *.T_NoVerify: ��У��ʱ��
   *.T_Valid: �Ƿ���Ч
   *.T_VIPTruck:�Ƿ�VIP
   *.T_HasGPS:��װGPS(Y/N)

   //---------------------------�̵�ҵ��������Ϣ--------------------------------
   *.T_MatePID:�ϸ����ϱ��
   *.T_MateID:���ϱ��
   *.T_MateName: ��������
   *.T_SrcAddr:������ַ
   *.T_DestAddr:�����ַ
   ---------------------------------------------------------------------------//

   ��Чƽ��Ƥ���㷨:
   T_PValue = (T_PValue * T_PTime + ��Ƥ��) / (T_PTime + 1)
  -----------------------------------------------------------------------------}

  sSQL_NewTruckLog = 'Create Table $Table(R_ID $Inc, T_ID varChar(15),' +
       'T_Truck varChar(15),T_Status Char(1), T_NextStatus Char(1),' +
       'T_IsHK Char(1),' +
       'T_InTime DateTime, T_InMan varChar(32),' +
       'T_OutTime DateTime, T_OutMan varChar(32),' +
       'T_BFPTime DateTime, T_BFPMan varChar(32), T_BFPValue $Float Default 0,' +
       'T_BFMTime DateTime, T_BFMMan varChar(32), T_BFMValue $Float Default 0,' +
       'T_FHSTime DateTime, T_FHETime DateTime, T_FHLenth Integer,' +
       'T_FHMan varChar(32), T_FHValue Decimal(15,5),' +
       'T_ZTTime DateTime, T_ZTMan varChar(32),' +
       'T_ZTValue $Float,T_ZTCount Integer, T_ZTDiff Integer)';
  {-----------------------------------------------------------------------------
   ������־:TruckLog
   *.T_ID:��¼���
   *.T_Truck:���ƺ�
   *.T_Status,T_NextStatus:״̬
   *.T_IsHK: �Ƿ�Ͽ�
   *.T_InTime,T_InMan:����ʱ��,������
   *.T_OutTime,T_OutMan:����ʱ��,������
   *.T_BFPTime,T_BFPMan,T_BFPValue:Ƥ��ʱ��,������,Ƥ��
   *.T_BFMTime,T_BFMMan,T_BFMValue:ë��ʱ��,������,ë��
   *.T_FHSTime,T_FHETime,
     T_FHLenth,T_FHMan,T_FHValue:��ʼʱ��,����ʱ��,ʱ��������,�Ż���
   *.T_ZTTime,T_ZTMan,
     T_ZTValue,T_ZTCount,T_ZTDiff:ջ̨ʱ��,������,�����,����,����
  -----------------------------------------------------------------------------}

  sSQL_NewHYReader = 'Create Table $Table(R_ID $Inc, H_ID varChar(32),' +
       'H_Name varChar(32), H_Host varChar(25), H_Port Integer,' +
       'H_Memo varChar(64))';
  {-----------------------------------------------------------------------------
   �Ÿڶ�������: HYReader
   *.R_ID: ���
   *.H_ID: ���������
   *.H_Name: ����
   *.H_Host: IP��ַ
   *.H_Port: �˿�
   *.H_Memo: ��ע
  -----------------------------------------------------------------------------}

  sSQL_NewPoundLog = 'Create Table $Table(R_ID $Inc, P_ID varChar(15),' +
       'P_Type varChar(1), P_Order varChar(20), P_Card varChar(16),' +
       'P_Bill varChar(20), P_Truck varChar(15), P_CusID varChar(32),' +
       'P_CusName varChar(80), P_MID varChar(32),P_MName varChar(80),' +
       'P_MType varChar(10), P_LimValue $Float,' +
       'P_PValue $Float, P_PDate DateTime, P_PMan varChar(32), ' +
       'P_MValue $Float, P_MDate DateTime, P_MMan varChar(32), ' +
       'P_FactID varChar(32), P_Station varChar(10), P_MAC varChar(32),' +
       'P_Direction varChar(10), P_PModel varChar(10), P_Status Char(1),' +
       'P_Valid Char(1), P_PrintNum Integer Default 1,' +
       'P_DelMan varChar(32), P_DelDate DateTime)';
  {-----------------------------------------------------------------------------
   ������¼: Materails
   *.P_ID: ���
   *.P_Type: ����(����,��Ӧ,��ʱ)
   *.P_Order: ������
   *.P_Bill: ������
   *.P_Truck: ����
   *.P_CusID: �ͻ���
   *.P_CusName: ������
   *.P_MID: ���Ϻ�
   *.P_MName: ������
   *.P_MType: ��,ɢ��
   *.P_LimValue: Ʊ��
   *.P_PValue,P_PDate,P_PMan: Ƥ��
   *.P_MValue,P_MDate,P_MMan: ë��
   *.P_FactID: �������
   *.P_Station,P_MAC: ��վ��ʶ
   *.P_Direction: ��������(��,��)
   *.P_PModel: ����ģʽ(��׼,��Ե�)
   *.P_Status: ��¼״̬
   *.P_Valid: �Ƿ���Ч
   *.P_PrintNum: ��ӡ����
   *.P_DelMan,P_DelDate: ɾ����¼
  -----------------------------------------------------------------------------}

  sSQL_NewProvider = 'Create Table $Table(R_ID $Inc, P_ID varChar(32),' +
       'P_Name varChar(80),P_PY varChar(80), P_Phone varChar(20),' +
       'P_Saler varChar(32),P_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   ��Ӧ��: Provider
   *.P_ID: ���
   *.P_Name: ����
   *.P_PY: ƴ����д
   *.P_Phone: ��ϵ��ʽ
   *.P_Saler: ҵ��Ա
   *.P_Memo: ��ע
  -----------------------------------------------------------------------------}

  sSQL_NewPicture = 'Create Table $Table(R_ID $Inc, P_ID varChar(32),' +
       'P_Name varChar(32), P_Mate varChar(80), P_Date DateTime, P_Picture Image)';
  {-----------------------------------------------------------------------------
   ͼƬ: Picture
   *.P_ID: ���
   *.P_Name: ����
   *.P_Mate: ����
   *.P_Date: ʱ��
   *.P_Picture: ͼƬ
  -----------------------------------------------------------------------------}

  //------------------------------------------------------------------------------
// ���ݲ�ѯ
//------------------------------------------------------------------------------
  sQuery_SysDict = 'Select D_ID, D_Value, D_Memo, D_ParamA, ' +
         'D_ParamB From $Table Where D_Name=''$Name'' Order By D_Index ASC';
  {-----------------------------------------------------------------------------
   �������ֵ��ȡ����
   *.$Table:�����ֵ��
   *.$Name:�ֵ�������
  -----------------------------------------------------------------------------}

  sQuery_ExtInfo = 'Select I_ID, I_Item, I_Info From $Table Where ' +
         'I_Group=''$Group'' and I_ItemID=''$ID'' Order By I_Index Desc';
  {-----------------------------------------------------------------------------
   ����չ��Ϣ���ȡ����
   *.$Table:��չ��Ϣ��
   *.$Group:��������
   *.$ID:��Ϣ��ʶ
  -----------------------------------------------------------------------------}

implementation

//------------------------------------------------------------------------------
//Desc: ���ϵͳ����
procedure AddSysTableItem(const nTable,nNewSQL: string);
var nP: PSysTableItem;
begin
  New(nP);
  gSysTableList.Add(nP);

  nP.FTable := nTable;
  nP.FNewSQL := nNewSQL;
end;

//Desc: ϵͳ��
procedure InitSysTableList;
begin
  gSysTableList := TList.Create;

  AddSysTableItem(sTable_SysDict, sSQL_NewSysDict);
  AddSysTableItem(sTable_ExtInfo, sSQL_NewExtInfo);
  AddSysTableItem(sTable_SysLog, sSQL_NewSysLog);
  AddSysTableItem(sTable_BaseInfo, sSQL_NewBaseInfo);

  AddSysTableItem(sTable_SerialBase, sSQL_NewSerialBase);
  AddSysTableItem(sTable_SerialStatus, sSQL_NewSerialStatus);

  AddSysTableItem(sTable_Card, sSQL_NewCard);
  AddSysTableItem(sTable_Picture, sSQL_NewPicture);
  AddSysTableItem(sTable_Provider, ssql_NewProvider);

  AddSysTableItem(sTable_Truck, sSQL_NewTruck);
  AddSysTableItem(sTable_TruckLog, sSQL_NewTruckLog);
  AddSysTableItem(sTable_HYReader, sSQL_NewHYReader);
//  AddSysTableItem(sTable_PoundLog, sSQL_NewPoundLog);
//  AddSysTableItem(sTable_PoundBak, sSQL_NewPoundLog);
end;

//Desc: ����ϵͳ��
procedure ClearSysTableList;
var nIdx: integer;
begin
  for nIdx:= gSysTableList.Count - 1 downto 0 do
  begin
    Dispose(PSysTableItem(gSysTableList[nIdx]));
    gSysTableList.Delete(nIdx);
  end;

  FreeAndNil(gSysTableList);
end;

initialization
  InitSysTableList;
finalization
  ClearSysTableList;
end.


