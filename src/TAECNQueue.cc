#include "inet/queueing/base/PacketQueueBase.h"
#include "inet/common/packet/Packet.h"
#include "inet/networklayer/common/EcnTag_m.h"
#include "inet/common/ModuleAccess.h"
#include "inet/common/InitStages.h"

using namespace inet;
using namespace inet::queueing;

class TAECNQueue : public PacketQueueBase
{
  protected:
    int packetCapacity = 100;
    double markThreshold = 0.8;
    simsignal_t queueLengthSignal;

    std::deque<Packet *> packets;
    b totalLength = b(0);   // ✅ strong type (bytes)

  protected:
    virtual void initialize(int stage) override {
        PacketQueueBase::initialize(stage);
        if (stage == INITSTAGE_LOCAL) {
            packetCapacity = par("packetCapacity");
            markThreshold  = par("markThreshold");
            queueLengthSignal = registerSignal("queueLength");
        }
    }

    virtual void pushPacket(Packet *packet, cGate *gate) override {
        int currentSize = getNumPackets();

        if (currentSize >= packetCapacity * markThreshold) {
            auto ecn = packet->addTagIfAbsent<EcnInd>();
            ecn->setExplicitCongestionNotification(3);  // ECN-CE
        }

        enqueuePacket(packet);
        cSimpleModule::emit(queueLengthSignal, (double)getNumPackets());
    }

    virtual Packet *pullPacket(cGate *gate) override {
        auto *pkt = dequeuePacket();
        cSimpleModule::emit(queueLengthSignal, (double)getNumPackets());
        return pkt;
    }

  public:
    // === Required pure virtual overrides ===
    virtual bool isEmpty() const override { return packets.empty(); }
    virtual int getNumPackets() const override { return packets.size(); }
    virtual int getMaxNumPackets() const override { return packetCapacity; }

    virtual b getTotalLength() const override { return totalLength; }
    virtual b getMaxTotalLength() const override { return b(-1); }

    virtual Packet *getPacket(int index) const override {
        return packets.at(index);
    }

    virtual void removePacket(Packet *packet) override {
        auto it = std::find(packets.begin(), packets.end(), packet);
        if (it != packets.end()) {
            totalLength -= (*it)->getTotalLength();   // ✅ fixed: same unit type
            packets.erase(it);
        }
    }

    virtual void removeAllPackets() override {
        for (auto *pkt : packets)
            delete pkt;
        packets.clear();
        totalLength = b(0);
    }

    // === Flow control helpers ===
    virtual bool canPushPacket(Packet *, cGate *) const override { return true; }
    virtual bool supportsPacketPushing(cGate *) const override { return true; }
    virtual bool supportsPacketPulling(cGate *) const override { return true; }
    virtual Packet *canPullPacket(cGate *) const override {
        return isEmpty() ? nullptr : packets.front();
    }

  protected:
    void enqueuePacket(Packet *pkt) override {
        packets.push_back(pkt);
        totalLength += pkt->getTotalLength();   // ✅ consistent b arithmetic
    }

    Packet *dequeuePacket() override {
        if (packets.empty()) return nullptr;
        Packet *pkt = packets.front();
        packets.pop_front();
        totalLength -= pkt->getTotalLength();   // ✅ consistent b arithmetic
        return pkt;
    }
};

Define_Module(TAECNQueue);
