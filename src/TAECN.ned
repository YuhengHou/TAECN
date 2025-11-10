package src;

import inet.common.misc.ThruputMeteringChannel;
import inet.node.inet.StandardHost;
import inet.node.ethernet.EthernetSwitch;
import inet.networklayer.configurator.ipv4.Ipv4NetworkConfigurator;

network TAECN
{
    parameters:
        int numSpines = default(2);
        int numLeafs  = default(2);
        int numHosts  = default(16);
        @display("bgb=1000,800");

    submodules:
        configurator: Ipv4NetworkConfigurator {
            parameters:
                @display("p=100,100");
        }

        spines[numSpines]: EthernetSwitch {
            parameters:
                @display("p=200+200*i,200");
        }

        leaves[numLeafs]: EthernetSwitch {
            parameters:
                @display("p=200+200*i,400");
        }

        hosts[numHosts]: StandardHost {
            parameters:
                @display("p=100+80*index,600;i=device/laptop");
                numApps = 1;
                app[0].typename = (index % 2 == 0) ? "TcpBasicClientApp" : "TcpSinkApp";
                app[0].connectAddress = (index % 2 == 0) ? ("hosts[" + string(index + 1) + "]") : "";
                app[0].connectPort = 5000;
                app[0].tOpen  = 0.1s;
                app[0].tSend  = 0.2s;
                app[0].tClose = 4.9s;
                app[0].sendBytes = 5MiB;
                app[0].thinkTime = 0s;
                app[0].idleInterval = 0s;
                hasTcp = true;
                hasUdp = false;
        }

    connections allowunconnected:
        for i = 0..numSpines - 1 {
            spines[i].ethg++ <--> ThruputMeteringChannel { delay = 5us; datarate = 10Gbps; } <--> leaves[0].ethg++;
            spines[i].ethg++ <--> ThruputMeteringChannel { delay = 5us; datarate = 10Gbps; } <--> leaves[1].ethg++;
        }

        for h = 0..numHosts - 1 {
            leaves[h % numLeafs].ethg++ <--> ThruputMeteringChannel { delay = 5us; datarate = 10Gbps; } <--> hosts[h].ethg++;
        }
};
