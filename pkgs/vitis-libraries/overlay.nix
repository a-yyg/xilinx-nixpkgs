final: prev:
let
  webpenc = prev.callPackage ./webpenc;
in
{
  # webpEncHost_nb1 = webpenc { nbInstances = 1; };
  # webpEncHost_nb2 = webpenc { nbInstances = 2; };
  webpEncHost_nb1_edge = webpenc { nbInstances = 1; platformNew = "edge"; };
  webpEncHost_nb2_edge = webpenc { nbInstances = 2; platformNew = "edge"; };
}
