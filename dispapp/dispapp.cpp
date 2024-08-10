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
		IHelloWorld* helloWorld = NULL;

		hr = CoCreateInstance(CLSID_CHelloWorld, NULL, CLSCTX_INPROC_SERVER, IID_IHelloWorld, (void**)&helloWorld);

		if (SUCCEEDED(hr))
		{
			int hint = 1;

			while (hint < 6)
			{
				BSTR result = NULL;

				hr = helloWorld->GetMessage(hint, &result);

				if (SUCCEEDED(hr))
				{
					printf("%S\n", result);

					if (result)
					{
						SysFreeString(result);
					}
				}
				else
				{
					break;
				}

				hint++;
			}

			helloWorld->Release();
		}

		CoUninitialize();
	}

	if (FAILED(hr))
	{
		fprintf(stderr, "0x%lx\n", (long)hr);
	}

	return FAILED(hr);
}
