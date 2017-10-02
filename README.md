# DenyTor
[Security] Application with PowerShell able to isolate Windows servers from DeepWeb, a solution that makes our servers inaccessible from ToR.

DenyTOR is a security tool created by Dani Alonso, expert cybersecurity and cloud solutions, and computer forensic judicial expert.

This tool establishes connection with a service hosted in Microsoft Azure, that monitor in real time the architecture of the TOR network. In the analysis identifies all the output nodes generating a complete list, which this script will be responsible for importing and processing it neglected.

Once the list of nodes in the TOR network is obtained, the script will create input and output rules in the Windows firewall according to our needs. We can establish the protection of our server when connecting to a wireless network [3], public [2], or on all networks [1]. For greater protection, option [1] is recommended. You can change the option at any time.

To see the results, you can open the Windows Firewall with Advanced Security tool and see the input and output rules.

There you will find the DenyTOR- # 00x rules, which host a series of remote IP addresses corresponding to the TOR output nodes. Do not edit the DenyTOR rules manually from the Windows Firewall. They will be overwritten when you run another option in DenyTOR again.

Option [4] will disable the TOR protection by eliminating all these rules.
