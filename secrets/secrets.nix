let
  yubikey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQChdVQFQy29aCt5Su4COANlKmtRv1yWmccAjGCd8M0+bxlUqkfS/QDK05NxSDN+9Tzj/ge6myExbXeKbWMrxl6r4Ib5kpB6Db8WpuFmvXqyOc/L8d3ZFcWdn1i2ZYyXgp+ipkZlwYYaDqbaq7e+pfInNHDIirxMrULBy8n6FZo+EpIURhs8fNK8ujLKFQ94P4n+zGv9rwVPetXnYEUis4ro/qKwYzBPKGWQngnFLd0HthWR9MovixOuCe+mHcb1JZeHMOZi8/HfLsho0UfokMjHoQ0wZdQM7VbHjVZUuyhFV1aJHls4FOK67l88kbDUUouDCymgqMXZWYupHyp0LpnhzHm5WfPIkBaQR2InspdaH0mEztQ1iobCmM27A4XfuiAgtpzSPuKYH061kSGuEJGUf762o8Fo70W9pdkkaQx68OCVC99Ccqs7R+FJESHE9IVRmOyzTJKdjG/+LWqCgyv/OeNb7IxEF1Jqwh4D6ZHKb7BX5ccbTgBBRzs71WySFJimSRmuxbzVI4fmzYc1n1dyir/hEZEBpcpKIrryrDz6Hdl4AfwKOwwt9Wnf+aBlA45tbd52ORGgAojOQ+0kLQ1ZjFoyJU26v4WS3cTUMoi71U8Z9KaNHlTFS2msU8YXwQlH5o/r3cnnnRb3ZtEPGm833lDYUxo0+B3JP9J2j1rpnw== cardno:17_970_358";
  yubikey-new = "age1yubikey1qfsvqhqcfweq094akgg9kyh0aw7nyhkyxmypshhcedyq24yzn8hnu68fhy3";
  fiyarr = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDONVtMzFjHs6Lfqw57zsdKGvxFzjhyc7zgn3ZvbMyiNdnDlTISei2nvNTTVpj278jB03SrSrY1WOGOOuNcErGuI6u/FvNo9lBCvhonTXWbBVEYkrMQifKBwKlHtHXs0zaQ55EAUh+rscFGYSP4a1HbCx4OLG4wGosRM7rC9zZI+QglyHX3V+zmw3hEutyPxL2yl+Zy2fxVWfo8AyXGaW0Re/DZFbFzdJtN71fQiJf5ONsKsa31FnTjML2GGf4L9oPvvt1ISWIY28muvGyAoGCE7L6Yk3SmHSrmEO4mhPdmuGdgqjwi785EeJMwkl+kGsJbGWLz0KyXxrInvkFEi9K6cU04Z9g+yCc0iYF+mPSnd/T7AoP2C4TW0lojEykW74df+fKYqBqj1W4EwO0ty4EN/VPbePwy6qZwthO1vNKAnzSRv92Ex0WdJTJ+rd9zxwCRXcQZZBzQCG0/9iTK71q1XjS+A5kBxPvsTrvlSHnPBfOTvCPIsVSZwSr5tbzF/nOULzed0roEwgz6/w+qMYf8aRKyygfBjFH88W9Si/T2Z8cCcNulKZdVx6WCCUw7z5i5dcsyxlh/5cYhDUDpQI7NJyhkYQ1eDtqXQxQw9aguYEwEFhwq4zP39F/A5+XuxYDdRMAvAzpcbsxUAfTUS2Lo3JJP3eY7qJvrPWLMuI1zDw== root@nixos";
  fiyarr-qbt = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDCfu7hqLeDxRlrE8lkK5WHMWm3WW1DrFgJ1pKzWtjAGe8AbWk5p5Hns+P2pZHYWQXxPxmLVEQ7bvCqyut5WjL74e681GdpAnsugV3s221PanDI/2zRqOapkcUu8TqXRnc8cq4ijE4EQJnahhBpUxUK+Uxuw3rGwZydzA3vzn6s9ddMceKkjwqhlTuzcNWxdwIlhRpDqtaSD3F32+Sb2Y/6jxkFt/TUYf6YZHHMbs7U7z0n9poTzcYqWLQg4kvSSJ1f/xOYV6foP8bAhoLNzlhfYMMJYxlNG9Io4W77nZME2CsZsPeXjNJddaBSAzria1jzAKjovopNt3oC4gGwb1ieFeagtGXrkyTInekQOB88rVReiEInRcoT0TCpzWSjgzMWQlET1vs+r+xSjpAuE8TosHdw1nckYDBwjkF0yqOIxf/1mcB5Ok1MHiUwqthkM8d6M4YYTCmO52oo1nUjr+oCzvEvcwJ/3ZZpqRRYpwlqZPwul0V011lDojAzLz7/44MG9NRzAO4cc4sX8ndixmXQ26vw54ydNm89vKp+DTmH7VOd9zkQLY2KKwvHHJkqnqZkPbnoNAh9ldgIiL/6Oyd2/jhDIIp/pjZdTwyehoLrE0bmJTibi58NFhzsYuE2SVnKFbJiW9WLV3qIJWFTI+KnpKkalrbGuEm72QS04boIuQ== root@fiyarr-qbt";
in
{
  "bitmagnet-env.age".publicKeys = [ yubikey fiyarr ];
  "airvpn-private-key.age".publicKeys = [ yubikey-new fiyarr-qbt ];
  "airvpn-preshared-key.age".publicKeys = [ yubikey-new fiyarr-qbt ];
  "airvpn-fiyarr-sk.age". publicKeys = [ yubikey-new fiyarr ];
  "airvpn-fiyarr-psk.age". publicKeys = [ yubikey-new fiyarr ];
}
