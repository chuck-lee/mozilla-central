/*
 * libjingle
 * Copyright 2004--2011, Google Inc.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *  3. The name of the author may not be used to endorse or promote products
 *     derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "talk/base/autodetectproxy.h"
#include "talk/base/gunit.h"
#include "talk/base/httpcommon.h"
#include "talk/base/httpcommon-inl.h"

namespace talk_base {

static const char kUserAgent[] = "";
static const char kPath[] = "/";
static const char kHost[] = "relay.google.com";
static const uint16 kPort = 443;
static const bool kSecure = true;
// Each of the two stages in AutoDetectProxy has a 2-second time-out, so 5
// seconds total should be enough.
static const int kTimeoutMs = 5000;

class AutoDetectProxyTest : public testing::Test, public sigslot::has_slots<> {
 public:
  AutoDetectProxyTest() : auto_detect_proxy_(NULL), done_(false) {}

 protected:
  bool Create(const std::string &user_agent,
              const std::string &path,
              const std::string &host,
              uint16 port,
              bool secure) {
    auto_detect_proxy_ = new AutoDetectProxy(user_agent);
    EXPECT_TRUE(auto_detect_proxy_ != NULL);
    if (!auto_detect_proxy_) {
      return false;
    }
    Url<char> host_url(path, host, port);
    host_url.set_secure(secure);
    auto_detect_proxy_->set_server_url(host_url.url());
    auto_detect_proxy_->SignalWorkDone.connect(
        this,
        &AutoDetectProxyTest::OnWorkDone);
    auto_detect_proxy_->Start();
    return true;
  }

  bool Run(int timeout_ms) {
    EXPECT_TRUE_WAIT(done_, timeout_ms);
    return done_;
  }

 private:
  void OnWorkDone(talk_base::SignalThread *thread) {
    AutoDetectProxy *auto_detect_proxy =
        static_cast<talk_base::AutoDetectProxy *>(thread);
    EXPECT_TRUE(auto_detect_proxy == auto_detect_proxy_);
    auto_detect_proxy_ = NULL;
    auto_detect_proxy->Release();
    done_ = true;
  }

  AutoDetectProxy *auto_detect_proxy_;
  bool done_;
};

// Test that proxy detection completes successfully. (Does not actually verify
// the correct detection result since we don't know what proxy to expect on an
// arbitrary machine.)
TEST_F(AutoDetectProxyTest, TestProxyDetection) {
  ASSERT_TRUE(Create(kUserAgent,
                     kPath,
                     kHost,
                     kPort,
                     kSecure));
  ASSERT_TRUE(Run(kTimeoutMs));
}

}  // namespace talk_base
