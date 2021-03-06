
class Match {
  has $.rule;
  has $.match_str;
  has $.from;
  has $.to;
  has $.bool;
  has $.hash;
  method make_from_rsfth($r,$s,$f,$t,$h) {
    self.new('rule',$r,'match_str',$s,'from',$f,'to',$t,'hash',$h);
  };
  method match_describe() {
    my $s = $.rule~"<"~$.from~","~$.to~",'"~$.match_str~"',{";
    for $.hash.keys {
      my $k = $_;
      my $v = $.hash{$k};
      my $vs = 'undef';
      if defined($v) {
        $vs = $v.match_describe;
      }
      $s = $s ~ "\n  "~$k~" => "~self.indent_except_top($vs)~",";
    }
    if $.hash.keys.elems {$s = $s ~ "\n"}
    $s = $s ~ "}>";
  };
  method indent($s) {
    $s.re_gsub(rx:P5/(?m:^(?!\Z))/,'  ')
  };
  method indent_except_top($s) {
    $s.re_gsub(rx:P5/(?m:^(?<!\A)(?!\Z))/,'  ')
  };
  method match_string() {
    $.match_str
  };
  method Str() {
    $.match_str.substr($.from, $.to-$.from)
  }
};
class ARRAY {
  method match_describe() {
    ("[\n" ~
     Match.indent(self.map(sub($e){$e.match_describe}).join(",\n")) ~
     "\n]")
  }
};
class HASH {
  method match_describe() {
    my $s = "{";
    for self.keys {
      my $k = $_;
      my $v = self.{$k};
      my $vs = 'undef';
      if defined($v) {
        $vs = $v.match_describe;
      }
      $s = $s ~ "\n  "~$k~" => "~Match.indent_except_top($vs)~",";
    }
    if self.keys.elems {$s = $s ~ "\n"}
    $s ~ "}"
  };
};
class STRING {
  method match_describe() {
    "'"~self~"'"
  }
}
class INTEGER {
  method match_describe() {
    "'"~self~"'"
  }
}
class FLOAT {
  method match_describe() {
    "'"~self~"'"
  }
}
