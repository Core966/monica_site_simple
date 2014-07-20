class CreatePosts < ActiveRecord::Migration
  def up
    create_table :posts do |t|
      t.string :title
      t.text :body
      t.boolean :is_deleted
      t.timestamps
    end
    Post.create(title: "My first post", body: "Quisque lobortis, velit ut aliquet interdum, tellus mauris ornare nunc, et dapibus tortor odio quis metus. Aenean sed velit vitae lorem dignissim fermentum. Praesent sit amet neque vehicula, pharetra sapien et, egestas quam. Suspendisse aliquet, massa a posuere scelerisque, velit orci hendrerit magna, ac elementum odio arcu quis ligula. Morbi lacus magna, tempus id enim vitae, imperdiet tempor nulla. Morbi sodales orci sapien, vitae hendrerit dolor hendrerit in. Praesent accumsan neque vel dui pretium iaculis. Suspendisse potenti. Phasellus interdum ut ligula vel fringilla. Praesent suscipit diam at fringilla molestie. Integer ut porta lectus. Sed rhoncus in massa quis dignissim. Curabitur orci arcu, egestas vel sem a, mollis aliquam risus. Nullam orci risus, viverra id aliquet vitae, adipiscing eget nulla. Suspendisse elementum facilisis elit eu commodo. Donec sollicitudin, ligula eget tempus luctus, metus urna sollicitudin tortor, ut iaculis erat sapien ac nisi.", is_deleted: false)
    Post.create(title: "My second post", body: "Duis tempor gravida enim, ut tempor arcu pretium aliquam. Pellentesque varius, mauris in accumsan sagittis, lacus nisl malesuada mi, ac placerat elit ipsum nec tortor. Ut eu metus nec justo interdum placerat quis id justo. Nullam sem nisi, rhoncus eget lectus non, auctor dictum dui. Nam bibendum diam facilisis semper placerat. Quisque eget tortor quis leo tempor eleifend quis nec dui. Nunc bibendum dapibus nibh vitae auctor. Pellentesque tempus pharetra purus a pharetra. Suspendisse libero urna, auctor ac eleifend ac, tincidunt eget risus. Proin congue enim sit amet augue vestibulum ornare in at ligula. Curabitur faucibus ullamcorper massa, a adipiscing turpis condimentum eget. Duis commodo diam sed volutpat porta. Maecenas placerat orci est, at tempor augue accumsan eleifend. Proin pellentesque posuere faucibus.", is_deleted: false)
    Post.create(title: "My third post", body: "Integer et viverra augue. Nullam nisi velit, pretium id fermentum vel, venenatis nec erat. Nam suscipit, diam vel cursus condimentum, turpis sem euismod metus, congue congue massa ipsum in odio. Etiam in tristique sapien. Cras eu auctor neque, sed consectetur libero. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Nullam venenatis consequat leo, a vehicula neque laoreet at. Ut lobortis in lectus eget convallis. Pellentesque non gravida sem. Aenean faucibus massa lorem, et hendrerit elit vestibulum et. Donec ut ultricies diam. Curabitur sit amet ligula nec elit condimentum fringilla quis non tortor. Proin accumsan porttitor nisl ut congue. Donec ac enim augue. Aliquam at odio sit amet nisl pharetra mollis nec placerat leo. Duis tempor quam augue, vitae ultrices felis tristique nec.", is_deleted: false)
  end
 
  def down
    drop_table :posts
  end
end
