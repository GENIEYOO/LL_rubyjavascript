## 20171128 AJAX

[1]ruby on rails 세팅

* 초기 설정 순서

```
-gem 설치 후 bundle
	설치 gem file 
	gem 'devise'
	gem 'kaminari'
	gem 'faker'
	gem 'bootstrap-sass' => @impoart 'bootstrap' in application.scss

-rails g scaffold posts title:string contents:text

-rails g devise:install

-rails g model comment post:references body:text

-rails g devise user

-rake db:migrate

```

* routes 파일 설정

```ruby
root 'posts#index'
devise_for :users
resources :posts do
	member do
		post '/create_comment' => 'posts#create_comment', as: 'create_comment_to'
      	post '/like_post' => 'posts#like_post'. as: 'like_to'
	end
  	collection do
    	delete '/:comment_id/destroy_comment' => 'posts#destroy_comment', as: 'destroy_comment_to'
    end
end
```

* application.html파일에 유저 sign in/sign out 만들기

```ruby
  
  <% if user_signed_in? %>
    <%= link_to "SIGN OUT", destroy_user_session_path, method: :delete, data: {confirm: "Are you sure?"} %>
  <% else %>
    <%= link_to "SIGN IN", new_user_session_path %>
  <% end %>
  
  <%= link_to "HOME", root_path %>
  <div class="container">    
    <%= yield %> 
  </div>
```

-yield는 리턴과 비슷한 개념

-div container로 묶어주면 뷰파일이 보기 좋게 spacing이 된다.

-create_comment.js.erb만들어주기

## ajax를 통해서 댓글 구현하기

1.form 태그 안에 input 태그 만들기

```ruby
<%=form_tag create_comment_to_post_path, id: "comment" do %>
	<%= text_field_tag comment[body]%>
	<%= submit tag "댓글달기" %>
<% end %>
```

2.form 태그 동작하지 않게 하기

3.submit 이벤트가 발생했을 경우에

4.input태그 안에 있는 값 가져오기

4-1 빈 칸인 경우 알림주기(skip)

5.jquery ajax를 이용해서 원하는 url로 데이터 보내기

```ruby
 var form = $('#comment');
    $(document).on('submit', '#comment', function(e) {
     e.preventDefault(); 
      //form 태그 동작하지 않게 하기
     var contents = form.serialize();//태그안에 값 가져오기
     //seriallize는 모든 인풋정보를 파라미터로 만들어준다.
     $.ajax({
         url: "<%=create_comment_to_post_path %>", 
         method: "POST",
         data: contents
       });
     });   
  })
```

5-1.로그인하지 않은 경우 알람주기

6.서버에서 댓글 등록하기

```javascript
  def create_comment
    unless user_signed_in?
      respond_to do |format|
        format.js { render 'please_login.js.erb'}
      end
    else
      puts params[:body]
      @c = @post.comments.create(comment_params)
    end
  end
```

8.페이지 refresh 없이 댓글 이어주기

```javascript
alert("댓글이 등록됨");
$('body').val("");
$('#comment_table tbody').append('<tr><td><%=@c.body %></td></tr>');
```



[참고] selector 바로 쓰는 것 보다 document 끌어서 쓰는 것이 좋다.

````javascript
$('css selector').on('eventName', function()) {         
                     });
$(document).on('eventName', 'css selector', function()) {
                     //이게 좋다.!!!
                     });
````



## 좋아요 버튼 + ajax구현

일단 like칼럼 DB가 필요하겠죠? 모델링!!!!!

```ruby
뷰에서 버튼을 만든 후 . 좋아요 모델이 필요하네? post reference /user reference 다 달려있어야함. M:N 관계 : 

-어떤 유저가 이 좋아요를 눌렀는지?

-어떤 포스트에 좋아요가 눌려있는지?

    rails g model like user:references post:references

-like 모델을 생성하는 데 user 와 post를 참고해. 즉 like에 user랑 post가 fk로 들어가.

-fk로 들어가면 모델에 has_many, 와 belongs_to의 선언에 따라 모델 모양이 달라짐.

post.rb 와 user.rb에 

has_many: likes

좋아요 버튼은 refresh하지 않아도 서버 정보가 아니어서 작동한다.

```



### 상세펑션

1. 좋아요 버튼을 누릅니다.

```javascript
 $('#like_button').on('click', function(e) {
    e.preventDefault
    $.ajax({
      method: "post",
      url: "<%=create_comment_to_post_path %>" 
      //요기로 보내줄거야.요기 템플릿 있어야해.
     })
  })
```

1. 버튼을 누른경우

   2-1. 기존에 좋아요를 이미 누른경우

   2-2. 기존에 좋아요를 누르지 않은경우

```ruby
 def like_post
 
    if Like.where(user_id: current_user.id, post_id: @post.id ).first.nil?
      @result = current_user.likes.create(post_id: @post.id)
      puts "좋아요 누름"
    else  
      @result= current_user.likes.find_by(post_id: @post.id).destroy
      puts "좋아요 취소"
    end
    @result = @result.frozen? //frozen개념 다시 check필요 아마 destroy되면 frozen되어서 dislike 버튼으로 바뀌는 거 같음.
 end
```

1. 이미 누른경우에는 좋아요 삭제 /기존에 누르지 않은 경우에는 좋아요 등록


1. 좋아요 버튼 바꿔주기 (like -> dislike)


like_post.js.erb(핵은 컨트롤러의 함수명과 일치해야함!)

```ruby
if(<%= @result %>) {
    $('#like_button').text("Like").addClass("btn-info").removeClass("btn-danger");
}
else {
     $('#like_button').text("Dislike").addClass("btn-danger").removeClass("btn-info");
}
$('#like_count').text(<%=@post.likes.count%>)
```



## ajax특징

-ajax는 바로 끌어올 수 없고 자바스크립트를 통해서 올 수 있다.	

-redirect_to posts 하면 안되고 ajax관련 페이지가 또 있으므로 template하나 만들어줘서 js format으로 받아와야함.

-ORM객체 DB개념

ORM객체 == DB row

Like.create => DB Row ++;

like.destroy => DB Row --;

@post.destroy

freeze :  destroy찍으면 메모리에는 존재하지만 디비에는 존재하지 않음.

-------------------------------

오늘 에러 잡은 거! 

-db:seed 에서도 모델 명이랑 컬럼명 같게 해서 migrate 한다.(모델-컬럼명!!)

-500에러는 template missing(에러 번호별 종류 이해하기!)

-답은 로그와 구글에 다 있다.!! 짝꿍 지혁 say 로그를 볼 생각!(습관!서버돌려서 얻는 로그 매우매우 중요!!)

-로그는 서버에서 가져오는데 대체 서버들이 가지고 있는 정보들이 뭐뭐지?

클라이언트와 서버가 가진 정보의 차이(궁금)

-로그 해석법 궁금 상세하게 공부해야할 것 같음.

```
Started POST "/posts/3/create_comment" for 203.246.196.65 at 2017-11-28 02:13:54 +0000
Cannot render console from 203.246.196.65! Allowed networks: 127.0.0.1, ::1, 127.0.0.0/127.255.255.255
Processing by PostsController#create_comment as */*
  Parameters: {"body"=>"ㅁㄹㅇㄴ", "id"=>"3"}
Completed 500 Internal Server Error in 9ms (ActiveRecord: 0.0ms)

NoMethodError (undefined method `pusts' for #<PostsController:0x007fe4fb715f60>
Did you mean?  puts):
  app/controllers/posts_controller.rb:65:in `create_comment'
```

-데이터를 받아오는 것은 잘 하고 confirm의 문제가 났는데 로그에도 안찍힘...

이유는 ""가 하나가 빠져서 .erb파일이 잘 먹지 않았음. 로직이 잘 작동할 때는

문법 에러

-자바 스크립트 : 콘솔창에서 아이디 확인(개발자도구 활용!!!)

-$(document).on('submit', '#comment', function(e)

-'document' 스트링으로 인지해서 미싱템플릿.

다른 언어도 메소드 스트링으로 쓰지 않게 늘 주의!!!! 수업 환경 동일하게 하는 것도 중요

-btn appending 에러 : elements 변화로 에러잡기 가능!

-아침에 gem devise:install 안하고 db migrate하다가 계속 튕김.

gem devise:install은 devise config파일 설정해줌! 이거해야 안꼬이고 DB 됨.

-순발력 기르기. c9 안되면 멍때리지말고 새로 파기. 새로하는거 귀찮아하지 말기

-멍때리기 없애기. 안될경우까지 가정해 3step 4step미리 생각해두기

-난 맨날 세팅이 안되있어서 허겁지겁 따라간다. 준비해놓고 멍때려라.

-끝나고 프로젝트 : DB모델링 할 때 SQL구문 활용까지 고려해서 짜기, ex) user1_t_table 이런식이면 앞에 user1은 select문으로 할 수 있음.
-메인 엔티티에 빨대 꽂게 만들기, 아니면 쿼리문 날리면 다른 엔티티 까지 같이 받아와야함.
-mysql문법공부
-궁금하면 내가 검색하기/누가 시키기 전에 내가 찾아서 하기/의견전달하기 전에 정리해서 하기