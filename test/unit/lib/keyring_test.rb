require File.dirname(__FILE__) + '/../../test_helper'
require 'keyring'

class KeyringTest < Test::Unit::TestCase
     
  def test_creation_and_encryption
    tmp = Tempfile.new('key_ring_test')
    tmp.close
    keyring = Keyring.create(public_key_data, tmp.path)

    info = keyring.extract_info
    assert_equal 'Gerrard Winstanley <diggers@revolt.org>', info[:email]
    assert_equal '45F1123007F1A5258B06D8987B0D6089532B1C44', info[:fingerprint]

    encrypted = keyring.encrypt_to(info[:fingerprint], secret)
    assert encrypted.grep('-----BEGIN PGP MESSAGE-----')
  ensure
    #tmp.unlink
  end

  def secret
    'this is a secret message'
  end

  def public_key_data
<<END
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.6 (GNU/Linux)

mQGiBEkCXTQRBAC3ZydotU1xgKwhJ83Ytg3REtFkOPmL5BT97anmEXM3fjRD2mYj
/d8ry6iUaee+xRzJsvQiFh8dhgJyMct+N+ctOaycFXQKpMgeFtLjBLu3A9UE8Jgv
ho7N0Hn8MdKGRVqMO6BDh90qAajBwLltZo9dh5QFRTsf5TLRsU4wo3EiiwCgr8hO
n5srPLXC6nauoAJOeqCT7zUD/0I6rKrnQb8m7qt1hjUdto0dYnfdxMcUaRMh7Vqu
UyYCOLrGmdK0X/REAEkcprOufKXcZDiuWKB9VvwQc3sJV48NqiYiscOmS1Abh9l6
wLS7j048Bz4jJryJlVSDmKIu7bHycfyL6+rFHg20tkSt7CPLFpaR/D0CueVc4JiB
e03mA/47DcKw6BlhNjyPNMyVrO0Fdte4ZeOwYi5IjJshNQMgqT5fj2oDvAYKkEk/
qBdiU4E4ZzCWkJk1mo+XKEbYoMeHpbJvMll7drRuckRVQNJ4ce4ufl6J7jJJVFPN
3vB/QzXoZynW+/EXiGIvMkPJGIBtZzQic7IUaN/esmoVVZLmErQnR2VycmFyZCBX
aW5zdGFubGV5IDxkaWdnZXJzQHJldm9sdC5vcmc+iGAEExECACAFAkkCXTQCGwMG
CwkIBwMCBBUCCAMEFgIDAQIeAQIXgAAKCRB7DWCJUyscRDUzAKCu37QHSrVOac2Z
WjeWC6oaL0EJnACfVogvEillGnqZYXpuTXtY4Ki+Oh25AQ0ESQJdNRAEAKXjkceN
LUGrv1Larv+69tcXkIR83sbhilpUfL8R+FNWX02MSH9CCbKhEcwBSiL1tKpPN8RP
GAXeVDCkLXt3VAh/RYPb7IB+u59S9zP2AETvwq9yhc2Q8kK34VsgbZNqXga/3EMP
4yg1tZEJsmPOIaObTprmSg0k1S8LPdOPyuZrAAMFBACSVPR4pbkx0KH1INPod6VF
Yu0sevOGtaj1wro9VgDs+aERu5qheEVAH1LPcATxaARkU/NPiPFwrYCUqfN0gxik
A2vNGrkjlhTkplh61aQ6q/AKDiEiy326cwnagGt6M5N9ncyWXAT9IZzbpnXn38av
9ZMfLo9yALYpR7PG8fME4YhJBBgRAgAJBQJJAl01AhsMAAoJEHsNYIlTKxxEqH4A
nRYofrk1tTYtGOwI9ZkJPHEYhWFnAJ9v3xM4Wsa9AATFQrgm94g4X2CLuw==
=G3JB
-----END PGP PUBLIC KEY BLOCK-----
END
  end

end


