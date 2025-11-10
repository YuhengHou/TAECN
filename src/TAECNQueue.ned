package src;

import inet.queueing.contract.IPacketQueue;
import inet.queueing.base.PacketQueueBase;

simple TAECNQueue extends PacketQueueBase like IPacketQueue
{
    parameters:
        @display("i=block/queue");
}
