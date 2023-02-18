#include <Windows.h>
#include<TlHelp32.h>
#include <iostream>
#include <tchar.h> 
#include <vector>


DWORD GetModuleBaseAddress(TCHAR* lpszModuleName, DWORD pID) { //               #1
    DWORD dwModuleBaseAddress = 0;
    HANDLE hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, pID); // make snapshot of all modules within process
    MODULEENTRY32 ModuleEntry32 = { 0 };
    ModuleEntry32.dwSize = sizeof(MODULEENTRY32);

    if (Module32First(hSnapshot, &ModuleEntry32)) //store first Module in ModuleEntry32
    {
        do {
            if (_tcscmp(ModuleEntry32.szModule, lpszModuleName) == 0) // if Found Module matches Module we look for -> done!
            {
                dwModuleBaseAddress = (DWORD)ModuleEntry32.modBaseAddr;
                break;
            }
        } while (Module32Next(hSnapshot, &ModuleEntry32)); // go through Module entries in Snapshot and store in ModuleEntry32


    }
    CloseHandle(hSnapshot);
    return dwModuleBaseAddress;
}
//################################################################################################
//#(I think) this + the game name locates the range of adresses (somthing like 0x732Ec - 0x739E9)#
//################################################################################################


int main() {

    HWND hGameWindow = FindWindow(NULL, L"AssaultCube"); //                     #2
    if (hGameWindow == NULL) { // error handle for if game is not open
        std::cout << "Start the game!" << std::endl;
        return 0;
    }
    DWORD pID = NULL; //                                                        
    GetWindowThreadProcessId(hGameWindow, &pID);
    HANDLE processHandle = NULL;
    processHandle = OpenProcess(PROCESS_ALL_ACCESS, FALSE, pID);
    if (processHandle == INVALID_HANDLE_VALUE || processHandle == NULL) { // error handling
        std::cout << "Failed to open process" << std::endl;
        return 0;
    }
//                                                                              #3
    TCHAR gameName[] = L"ac_client.exe";//    #1(   #3,      #2)
    DWORD gameBaseAddress = GetModuleBaseAddress((gameName), pID);
    DWORD offsetGameToBaseAdress = 0x17E0A8;
    DWORD baseAddress = NULL;
    DWORD pointsAddress = baseAddress; //the Adress we need -> change now while going through offsets
    //##########################################################
    //# #1-3 are all used to get a base for all of the pointers#
    //##########################################################

    int addrs = 1;
    int poopoop = 1;
    int newammo = 10;
    //                                             base(exe)     base without pointers
    ReadProcessMemory(processHandle, (LPVOID)(gameBaseAddress + offsetGameToBaseAdress), &baseAddress, 4, 0);
    std::cout << "Address: " << addrs << std::endl;
    //                                        previous + offset
    ReadProcessMemory(processHandle, (LPVOID)(baseAddress + 0x364), &addrs, 4, 0);
    std::cout << "Address: " << addrs << std::endl;
    //                                        previous + offset
    ReadProcessMemory(processHandle, (LPVOID)(addrs + 0x14), &addrs, 4, 0);
    std::cout << "Address: " << addrs << std::endl;
    DWORD save = addrs; // used for write
    //                                        previous + offset
    ReadProcessMemory(processHandle, (LPVOID)(addrs + 0x0), &addrs, 4, 0);
    std::cout << "Address: " << addrs << std::endl;
    //                                        previous + offset
    WriteProcessMemory(processHandle, (LPVOID)(save + 0x0), &newammo, 4, 0);

    //Can be condesned as,      (LPVOID)(gameBaseAddress + offsetGameToBaseAdress), &var
    //then,                     (LPVOID)(var + 0x364 + 0x14 + 0x0)
    //  |
    // \|/
    //ReadProcessMemory(processHandle, (LPVOID)(gameBaseAddress + offsetGameToBaseAdress), &baseAddress, 4, 0);
    //ReadProcessMemory(processHandle, (LPVOID)(addrs + 0x364 + 0x14 + 0x0), &addrs, 4, 0);

}
