/***********************************
 * Copyright (c) 2024 Roger Brown.
 * Licensed under the MIT License.
 ****/

#include <objbase.h>
#include <stdio.h>
#include <displib_h.h>

int main(int argc, char** argv)
{
	HRESULT hr = CoInitializeEx(NULL, COINIT_MULTITHREADED);

	if (SUCCEEDED(hr))
	{
		BSTR app = SysAllocString(L"RhubarbGeekNz.InprocServer32");
		CLSID clsid;

		hr = CLSIDFromProgID(app, &clsid);

		SysFreeString(app);

		if (SUCCEEDED(hr))
		{
			IHelloWorld* helloWorld = NULL;

			hr = CoCreateInstance(clsid, NULL, CLSCTX_INPROC_SERVER, IID_IHelloWorld, (void**)&helloWorld);

			if (SUCCEEDED(hr))
			{
				BSTR result = NULL;
				int hint = argc > 1 ? atoi(argv[1]) : 1;

				hr = helloWorld->GetMessage(hint, &result);

				if (SUCCEEDED(hr))
				{
					printf("%S\n", result);

					if (result)
					{
						SysFreeString(result);
					}
				}

				helloWorld->Release();
			}

			if (FAILED(hr))
			{
				fprintf(stderr, "0x%lx\n", (long)hr);
			}
		}

		CoUninitialize();
	}

	return FAILED(hr);
}
