object ClientModule1: TClientModule1
  OldCreateOrder = False
  Height = 209
  Width = 263
  object SQLConnection1: TSQLConnection
    DriverName = 'DataSnap'
    LoginPrompt = False
    Params.Strings = (
      'DriverUnit=Data.DBXDataSnap'
      
        'DriverAssemblyLoader=Borland.Data.TDBXClientDriverLoader,Borland' +
        '.Data.DbxClientDriver,Version=23.0.0.0,Culture=neutral,PublicKey' +
        'Token=91d62ebb5b0d1b1b'
      'Port=211'
      'HostName=192.168.1.6'
      'CommunicationProtocol=tcp/ip'
      'DatasnapContext=datasnap/'
      'Filters={}')
    Left = 48
    Top = 40
    UniqueId = '{1E2DED18-D0E4-4D28-88C0-6083E99240E8}'
  end
end
