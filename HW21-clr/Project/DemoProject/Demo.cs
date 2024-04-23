using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.IO;
using System.IO.Compression;

public class FileCompressCLR
{
    [Microsoft.SqlServer.Server.SqlFunction(IsDeterministic = true, DataAccess = DataAccessKind.None)]

    //Загрузка файла в виде бинарника, на входе Полный путь к файлу
    public static SqlBytes LoadFile(string FileName)
    {
        FileStream file = new FileStream(FileName, FileMode.Open, FileAccess.Read, FileShare.Read);

        MemoryStream ms = new MemoryStream();
        int sourcebyte = file.ReadByte();
        while (sourcebyte != -1)
        {
            ms.WriteByte((byte)sourcebyte);
            sourcebyte = file.ReadByte();
        }

        file.Close();
        return new SqlBytes(ms);
    }

    //Загрузка файла в виде бинарника с компрессией, на входе Полный путь к файлу
    public static SqlBytes LoadCompressFile(string FileName)
    {
        FileStream file = new FileStream(FileName, FileMode.Open, FileAccess.Read, FileShare.Read);
        byte[] buffer = new byte[file.Length];
        file.Read(buffer, 0, buffer.Length);
        file.Close();

        MemoryStream ms = new MemoryStream();

        DeflateStream compress = new DeflateStream(ms, CompressionMode.Compress, true);
        compress.Write(buffer, 0, buffer.Length);

        compress.Close();
        compress = null;

        return new SqlBytes(ms);
    }

    //Выгрузка файла в указанный источник
    public static string SaveFile(string FileName, SqlBytes CompressedFile)
    {
        if (CompressedFile.IsNull)
            return "Error";

        try
        {

            FileStream file = File.Create(FileName);

            int sourcebyte = CompressedFile.Stream.ReadByte();
            while (sourcebyte != -1)
            {
                file.WriteByte((byte)sourcebyte);
                sourcebyte = CompressedFile.Stream.ReadByte();
            }
            file.Close();
                       

        }

        catch (Exception)
        {
            return "Error";
        }

        return "OK";
    }

    //Выгрузка файла в указанный источник с предварительной декомпрессией
    public static string SaveDecompressFile(string FileName, SqlBytes CompressedFile)
    {
        if (CompressedFile.IsNull)
            return "Error";

        DeflateStream decompress = new DeflateStream(CompressedFile.Stream, CompressionMode.Decompress, true);

        try
        {

            FileStream file = File.Create(FileName);

            int sourcebyte = decompress.ReadByte();
            while (sourcebyte != -1)
            {
                file.WriteByte((byte)sourcebyte);
                sourcebyte = decompress.ReadByte();
            }

            file.Close();
        }

        catch (Exception)
        {
            return "Error";
        }

        finally
        {
            decompress.Close();
            decompress = null;
        }

        return "OK";
    }
    
}