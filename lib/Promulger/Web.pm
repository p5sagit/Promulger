package Promulger::Web;
use Web::Simple 'Promulger::Web';
use autodie;

use Promulger::List;

use Method::Signatures::Simple;

has list_home => (
  is => 'ro',
  default => sub { 'etc/lists' },
  lazy => 1,
);

sub dispatch_request {
  my ($self) = shift;
  sub (GET + /list/) {
    redispatch_to '/index';
  },
  sub (GET + /list) {
    redispatch_to '/index';
  },
  sub (GET + /) {
    redispatch_to '/index';
  },
  sub (GET + /index) {
    my ($self) = @_;
    [ 200, [ 'Content-type', 'text/html' ], [ $self->render_index(@_) ] ]
  },
  sub (GET + /list/*/) {
    my ($self, $list) = @_;
    redispatch_to "/list/${list}";
  },
  sub (GET + /list/*) {
    my ($self, $list) = @_;
    [ 200, [ 'Content-type', 'text/html' ], [ $self->show_list($list) ] ]
  },
  sub (GET + /list/*/subscriber/* + .*) {
    my ($self, $list, $subscriber, $extension) = @_;
    [ 
      200, 
      [ 'Content-type', 'text/html' ], 
      [ $self->show_subscriber($list, $subscriber, $extension) ] 
    ]
  },
  sub (POST + /list/*/subscriber/*/unsubscribe) {
    my ($self, $list, $subscriber) = @_;
    [ 
      200, 
      [ 'Content-type', 'text/html' ], 
      [ $self->unsubscribe($list, $subscriber) ] 
    ]
  },
  sub (POST + /list/*/subscribe + %email=) {
    my ($self, $list, $email) = @_;
    [ 
      200, 
      [ 'Content-type', 'text/html' ], 
      [ $self->subscribe($list, $email) ],
    ]
  },
  sub () {
    [ 405, [ 'Content-type', 'text/plain' ], [ 'Method not allowed' ] ]
  }
}

method render_index {
  my ($self) = @_;
  my @lists = Promulger::List->get_lists;
  my $html = <<HTML;
<p>Promulger</p>

<p>Lists:</p>
<ul>
HTML
  for my $list (@lists) {
    $html .= qq{<li><a href="/list/${list}">${list}</a></li>};
  }
  $html .= "</ul>";
  return $html;
}

method show_list($list_name) {
  my $list = Promulger::List->resolve($list_name);
  my $name = $list->listname;
  my $active = $list->active;
  my @subscribers = keys %{ $list->subscribers };
  my $html = <<"HTML";
<p>List: ${name}</p>
<p>Active: ${active}</p>
<form method="POST" action="/list/${list_name}/subscribe">
<input type="text" name="email">
</form>
<p>Subscribers:</p>
<ul>
HTML
  for my $sub (@subscribers) {
    $html .= qq{<li><a href="/list/${name}/subscriber/${sub}">${sub}</a></li>};
  }
  $html .= "</ul>";
  return $html;
}

method subscribe($list_name, $email) {
  my $list = Promulger::List->resolve($list_name);
  $list->subscribe($email);
  return "<p>Subscribed ${email} to ${list_name}.</p>";
}

method unsubscribe($list_name, $email) {
  my $list = Promulger::List->resolve($list_name);
  $list->unsubscribe($email);
  return "<p>Unsubscribed ${email} from ${list_name}.</p>";
}

method show_subscriber($list_name, $subscriber, $extension) {
  my $address = "${subscriber}.${extension}";
  my $html = <<"HTML";
<p>Subscriber ${address}</p>
<form method="POST" action="/list/${list_name}/subscriber/${address}/unsubscribe">
<input type="submit" value="Unsubscribe">
</form>
HTML
}

1;
