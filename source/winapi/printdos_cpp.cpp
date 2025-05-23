//
// CLASS PrintDos
//
// Copyright (c) Sandro Freire <sandrorrfreire@yahoo.com.br>
// for HwGUI By Alexander Kresin
//

// txtfile.c
// AFILLTEXT(cFile) -> aArray
// NTXTLINE(cFile)  -> nLines

#include <hbapi.hpp>
#include <hbapiitm.hpp>
#include <hbstack.hpp>
#ifdef __XHARBOUR__
#include <hbfast.h>
#endif
#include <windows.h>

#undef LINE_MAX
// #define LINE_MAX 4096
// #define LINE_MAX 8192
// #define LINE_MAX 16384
#define LINE_MAX 0x20000
//----------------------------------------------------------------------------//
static int file_read(FILE *stream, char *string)
{
  int ch;
  auto cnbr = 0;

  memset(string, ' ', LINE_MAX);

  for (;;)
  {
    ch = fgetc(stream);

    if ((ch == '\n') || (ch == EOF) || (ch == 26))
    {
      string[cnbr] = '\0';
      return (ch == '\n' || cnbr);
    }
    else
    {
      if (cnbr < LINE_MAX && ch != '\r')
      {
        string[cnbr++] = (char)ch;
      }
    }

    if (cnbr >= LINE_MAX)
    {
      string[LINE_MAX] = '\0';
      return (1);
    }
  }
}

//----------------------------------------------------------------------------//
HB_FUNC(AFILLTEXT)
{
  auto pSrc = hb_parc(1);
  auto pArray = hb_itemNew(nullptr);
  auto pTemp = hb_itemNew(nullptr);

  if (!pSrc)
  {
    hb_reta(0);
    return;
  }

  if (strlen(pSrc) == 0)
  {
    hb_reta(0);
    return;
  }

  FILE *inFile = fopen(pSrc, "r");

  if (!inFile)
  {
    hb_reta(0);
    return;
  }

  auto string = static_cast<char *>(hb_xgrab(LINE_MAX + 1));
  hb_arrayNew(pArray, 0);

  while (file_read(inFile, string))
  {
    hb_arrayAddForward(pArray, hb_itemPutC(pTemp, string));
  }

  hb_itemRelease(hb_itemReturn(pArray));
  hb_itemRelease(pTemp);
  hb_xfree(string);
  fclose(inFile);
}

HB_FUNC(HWG_WIN_ANSITOOEM)
{
  auto pString = hb_param(1, Harbour::Item::STRING);

  if (pString)
  {
    int nLen = (int)hb_itemGetCLen(pString);
    auto pszSrc = hb_itemGetCPtr(pString);

    int nWideLen = MultiByteToWideChar(CP_ACP, MB_PRECOMPOSED, pszSrc, nLen, nullptr, 0);
    auto pszWide = static_cast<LPWSTR>(hb_xgrab((nWideLen + 1) * sizeof(wchar_t)));

    MultiByteToWideChar(CP_ACP, MB_PRECOMPOSED, pszSrc, nLen, pszWide, nWideLen);

    nLen = WideCharToMultiByte(CP_OEMCP, 0, pszWide, nWideLen, nullptr, 0, nullptr, nullptr);
    auto pszDst = static_cast<char *>(hb_xgrab(nLen + 1));

    WideCharToMultiByte(CP_OEMCP, 0, pszWide, nWideLen, pszDst, nLen, nullptr, nullptr);

    hb_xfree(pszWide);
    hb_retclen_buffer(pszDst, nLen);
  }
  else
  {
    hb_retc_null();
  }
}
