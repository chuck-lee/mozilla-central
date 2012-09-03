/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

// Original author: ekr@rtfm.com

#include "logging.h"
#include "transportflow.h"
#include "transportlayerlog.h"

MLOG_INIT("mtransport");

void TransportLayerLogging::WasInserted() {
  if (downward_) {
    downward_->SignalStateChange.connect(
        this, &TransportLayerLogging::StateChange);
    downward_->SignalPacketReceived.connect(
        this, &TransportLayerLogging::PacketReceived);
    SetState(downward_->state());
  }
}

TransportResult
TransportLayerLogging::SendPacket(const unsigned char *data, size_t len) {
  MLOG(PR_LOG_DEBUG, LAYER_INFO << "SendPacket(" << len << ")");

  if (downward_) {
    return downward_->SendPacket(data, len);
  }
  else {
    return static_cast<TransportResult>(len);
  }
}

void TransportLayerLogging::StateChange(TransportLayer *layer, State state) {
  MLOG(PR_LOG_DEBUG, LAYER_INFO << "Received StateChange to " << state);

  SetState(state);
}

void TransportLayerLogging::PacketReceived(TransportLayer* layer,
                                           const unsigned char *data,
                                           size_t len) {
  MLOG(PR_LOG_DEBUG, LAYER_INFO << "PacketReceived(" << len << ")");
  
  SignalPacketReceived(this, data, len);
}



