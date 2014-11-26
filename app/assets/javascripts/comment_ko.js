var commentContext;

function Comment(data) {
  var self = this;
  self.user_id     = ko.observable(data.user_id);
  self.user_name   = ko.observable(data.user_name);
  self.user_avatar_url = ko.observable(data.user_avatar_url);
  self.location_plan_id = ko.observable(data.location_plan_id);
  self.grade_id    = ko.observable(data.grade_id);
  self.cause       = ko.observable(data.cause);
  self.body        = ko.observable(data.body);
  self.created_at  = ko.observable(new Date(data.created_at));
  self.timestamp   = ko.observable(data.timestamp);
}

function CommentViewModel() {
  var self = this;

  self.location_plan_id = ko.observable(0);
  self.new_body  = ko.observable("");
  self.comments = ko.observableArray([]);

  self.url = ko.pureComputed(function() {
    return "/location_plans/" + self.location_plan_id() + "/comments";
  });

  self.fetch_data = function() {
    $.ajax(self.url(), {data: {page: 1}} )
      .done(function(data, status, xhr) {
        console.log(data);
        self.load(data);
      })
      .fail(function(xhr, status, error) {
        alert("Error loading comments");
        console.log("Error loading comments");
        console.log(xhr);
        console.log(status);
        console.log(error);
      });
  };

  self.load = function(data) {
    var c = jQuery.map(data, function(comment, i){ // Actually a flatmap. Stupid jQuery
      return new Comment(comment);
    });

    self.comments(c);
  };

  self.add_comment = function() {
    var data = {comment: {body: self.new_body()}};

    $.ajax(self.url(), {type: 'POST', data: data})
      .done(function(data, status, xhr) {
        self.comments.unshift(new Comment(data));
        self.new_body("");
      })
      .fail(function(xhr, status, error) {
        alert("Error creating comment");
        console.log("Error creating comment");
        console.log(xhr);
        console.log(status);
        console.log(error);
      });
  };
}

$(document).ready(function() {
  var comment_view = $('#comment_view');
  var d = comment_view.data();
  if(d) {
    commentContext = new CommentViewModel();
    ko.applyBindings(commentContext);

    commentContext.location_plan_id(d.locationPlanId);
    commentContext.fetch_data()
  }
});
