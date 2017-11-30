# 20171129 ajax

## 댓글 삭제 기능 추가

````java
 <% @post.comments.reverse.each do |p| %>
      <tr id = "comment-<%= p.id %>">
        <td><%=p.body %></td>
      <td><%= link_to "삭제", destroy_comment_to_posts_path(p.id), method: :delete, data: {confirm: "삭제하시겠습니까?"}, class: "btn btn-warning", remote: true %></td>
      </tr>
      <% end %>
````

routes.rb파일 설정

```
member do
-/posts/:id/{내가 설정한 url}
collection do
/posts/{내가 설정한 url}
```

-댓글을 달 때 어떤 것을 추가했는지 확인

-.json을 붙여주면 우리가 작성했던 글이  json형태로 받아짐.

## 스크롤해서 ajax로 글 리스트 목록 가져오기

* paginate - kaminari
* 어떤 event에 메소드를 달까 scroll에

Faker로  seed에서 list 목록 늘리기

```ruby
1000.times do
    Post.create(
        title: Faker::Name.title,
        contents: Faker::Lorem.sentence
        )
end
```

routes.rb 파일 수정

```ruby
collection do
      delete '/:comment_id/destroy_comment' => 'posts#destroy_comment', as: 'destroy_comment_to'
      get '/page_scroll' => 'posts#page_scroll', as: 'scroll'
    end
```

스크롤 하기 위해서는 브라우져 뷰 개념 알아야 함.

![웹페이지개념](C:\Users\student\Desktop\웹페이지개념.png)

* window - 지금 보고 있는 창

* document - 맨앞에서 맨 끝까지의 높이

  -console창에서 높이 확인

  $(window).scrollTop();

  $(window).height();

  $(document).height();

  w.scrollTop >= d.height - w.height

* controller 파일 데이터받아오게 만들어주기

  ```ruby
    def page_scroll
     @posts = Post.order("created_at").page(params[:page])
    end
  ```

* page_controller.js.erb

* tableID는 미리 인덱스뷰파일에서 지정해 주고, tbody써준 후에 붙여야 제대로 들어감 .안그러면 테이블 엉킴.

```ruby
<% @posts.each do |post| %>
    $('#mytable tbody').append(
    `
   <tr>
        <td><%= post.id %></td>
        <td><%= post.title %></td>
        <td><%= truncate post.contents, length: 20 %></td>
        <td><%= link_to 'Show', post %></td>
        <td><%= link_to 'Edit', edit_post_path(post) %></td>
        <td><%= link_to 'Destroy', post, method: :delete, data: { confirm: 'Are you sure?' } %></td>
    </tr>
    `
    );
<% end %>
```

* post출력 개수 조정하고 싶다면 port.rb파일에 paginate_per 40으로

===========================================



##댓글에 validation 주기

우리가 원하는 길이인지?(최소, 최대)

우리가 원하는 형태인지?

우리가 원하는 검사?

comment.rb

```ruby
 def self.MAX_LENGTH
    40#숫자만 변경해주면 된다.
  end
  belongs_to :post
  validates :body, length: {maximum: self.MAX_LENGTH},
                   presence: true #빈 칸 안되고 40자
```



show.html

```javascript
<h3><span id = "word_count">0</span>/<%=Comment.MAX_LENGTH%></h3> 
....
  var max_text_length = <%=Comment.MAX_LENGTH%> ;
    $('#comment').on('keyup', function() {
      var text_length=$('#comment_body').val().length;
      $('#word_count').addClass('text-success').removeClass('text-danger');
      // console.log(text_length);
      if(text_length > max_text_length) {
        alert("최대길이 넘음");
        $('#word_count').addClass('text-danger').removeClass('text-success');
        $('#comment_body').val($('#comment_body').val().substr(0, max_text_length));
        text_length = $('#comment_body').val().length;
      }
    $('#word_count').text(text_length);
    })
```

.keyup() 값이 입력되었을 때 그 키가 입력되자마자 바로 인출시켜주는 이벤트 + .length로 글자 세기

post_controller.rb



front/back

----------------------------------------

에러 잡은거!

-변수명이 맞지 않아서 nilclass 변수가 못받와서

<% @post.comments.reverse.each do |p| %>

​	p.!!

<% end %>

-routes 에러 rake routes

-c9 에서 창 옆에 파일 창은 글씨 작게 해서 파일명 보이게 하고, 코드 내용은 크게 한다

-에러 났을 때 source 창 확인.

-bundle exec rake db:seed : rails 버전차이

bundle update

-comma안써서 틀림 data에 syntax에러 sources로 확인해 봤는데

,없었는데 난 데이터로만 생각했음. x가 그렇게 찍혀서.

그런데 앞에 것을 생각해야 했음.

```javascript
$.ajax({
           method: "GET",
           url: "/posts/page_scroll",
           data: {
             page: page_scroll_index++
           }
```

-댓글이 생성되었을 때 삭제버튼이 같이 나오게 하려면?

```javascript
<td><%= link_to 'Destroy', post, method: :delete, data: { confirm: 'Are you sure?' } %></td>
```

-모든 언어 메소드 줄이는게 제일 좋다.

-[다혜찡이 알려준 터미널 shellplugin적용] : 

-https://stackoverflow.com/questions/25763017/install-oh-my-zsh-on-a-vagrant-box-as-part-of-the-bootstrap-process

-https://draculatheme.com/atom/





잘 고치지 않은 파일들은 vendor에서 관리

부트스트랩 파일 보면 vendor에 넣을 파일들이 정해져 있다.

app-asset이랑 vendor에 넣을 파일이랑 다름

```
gem 'bootstrap-sass'
gem 'font_awsome_rails'

gem 'faker'

gem 'kaminari'

gem 'devise'

rails g scaffold post title:string contents:text

```





rails g devise:install



rake db:migrate



root  'posts#index'



application .scss

@import ''; 해가 면서 한다.

atom창으로 이용할 페이지 켜놓고 div옮겨 가면서!!!



form_for는 자동으로 value 값 잡아준다.



require 'jaBootstrapValidation' - 폼 유효성 검사 플러그인

fa는 fontawesome class class로 임포트 하면 쓸 수 있다.

fa 쓰면 클래스로

아톰 창 켜놓고 하기