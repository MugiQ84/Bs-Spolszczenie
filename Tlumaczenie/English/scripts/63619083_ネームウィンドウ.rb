#===========================================================================

# ◆ A1 Scripts ◆

#    ネームウィンドウ（RGSS2/RGSS3共用）

#

# バージョン   ： 2.40 (2012/01/19)

# 作者         ： A1

# URL　　　　　： http://a1tktk.web.fc2.com/

#---------------------------------------------------------------------------

# 機能：

# ・ネームウィンドウを表示します

#---------------------------------------------------------------------------

# 更新履歴　　 ：2011/12/15 Ver1.00 リリース

#         　　 ：2011/12/29 Ver1.10 アクター名表示対応

#         　　 ：2011/12/30 Ver2.00 左右顔グラフィック対応

#         　　 ：2011/12/30 Ver2.00 表示位置「上」対応

#         　　 ：2011/12/30 Ver2.10 RGSS2対応

#         　　 ：2011/12/30 Ver2.11 名前が切り替わる度にウィンドウを閉じる不具合を修正

#         　　 ：2012/01/02 Ver2.20 同じ顔グラフィックの別名表示機能追加

#         　　 ：2012/01/02 Ver2.20 表示名の直接指定機能追加

#         　　 ：2012/01/02 Ver2.30 A1共通スクリプトVer3.30対応

#         　　 ：2012/01/19 Ver2.40 バトルネームウィンドウ対応

#---------------------------------------------------------------------------

# 設置場所      

#　　A1共通スクリプトより下

#　　(左右顔グラフィックスクリプトより下)

#

# 必要スクリプト

#    A1共通スクリプトVer3.30以上

#---------------------------------------------------------------------------

# 使い方

#　設定項目を設定します

#　

#　  設定項目の「表示する名前」を Actor[ID] とすると

#　  IDで指定したアクターの名前を表示します

#　

#　イベントコマンド「注釈」に記述

#

#　　ネームウィンドウ on|off

#      表示の on/off を切り替えます

#

#    NWインデックス index

#      同じ顔グラフィックに複数の名前を配列で登録している場合

#      次に表示するネームウィンドウを指定した index の名前を使用します

#      省略時には 0番目 の名前を使用します

#

#    NW名前指定 Name

#      次に表示するネームウィンドウに Name を使用します

#      顔グラフィックなしでも表示されます

#================Rozszpunka======================================================

$imported ||= {}

$imported["A1_Name_Window"] = true

if $imported["A1_Common_Script"]

old_common_script("ネームウィンドウ", "3.30") if common_version < 3.30

#==============================================================================

# ■ 設定項目

#==============================================================================

module A1_System::NameWindow



  #--------------------------------------------------------------------------

  # ネームウィンドウを使用するクラス

  #--------------------------------------------------------------------------

  USE_NAME_WINDOW_CLASS = [Window_Message]

  

  #--------------------------------------------------------------------------

  # ネームウィンドウのフォント

  #--------------------------------------------------------------------------

  NAME_FONT = "UmePlus Gothic"

  

  #--------------------------------------------------------------------------

  # 長い名前の時に左(右)に寄せる

  #--------------------------------------------------------------------------

  FIX_LONG_NAME = false

  

  #--------------------------------------------------------------------------

  # 顔グラフィックと名前の対応

  #

  #  "[ファイル名]_[Index]" => "表示する名前" ※Index毎に設定

  #  "[ファイル名]"         => "表示する名前" ※該当ファイル全てに適用

  #                            "Actor[ID]"    ※該当するIDのアクター名を表示

  #--------------------------------------------------------------------------

  NAME_LIST = {

    "aka"    => "Red Hood",

    "ri-hu"    => "Fairy Leaf",

    "alice"    => "Alice",

    "alice2"    => "Alice",

    "jnnu"    => "Holy Knight Jeanne",

    "doro"    => "Witch Dorothy",

    "eriza"    => "Soul Lady Elisabeth",

    "eruma"    => "Match Seller Elma",

    "beru"    => "Beauty La Belle",

    "biku"    => "Maid Victoria",

    "gu-su"    => "Rich Bird Goose",

    "kata"    => "Saint Catherine",

    "miranda"    => "Black Condemner Miranda",

    "kaeru"    => "Princess Frog",

    "nin"    => "Little Mermaid",

    "lap"    => "Rapunzel",

    "sira"    => "Snow White",

    "sin"    => "Cinderella",

    "poro"    => "Poro",

    "ri-hu2"    => "Mary Sue",

    "maria"    => "Prostitute Marianna",

    "hen"    => "Hansel",

    "gure"    => "Gretel",

    "ba"    => "Black Judge Baphomet",

  }

end

#==============================================================================

# ■ Cache

#------------------------------------------------------------------------------

# 　各種グラフィックを読み込み、Bitmap オブジェクトを作成、保持するモジュール

# です。読み込みの高速化とメモリ節約のため、作成した Bitmap オブジェクトを内部

# のハッシュに保存し、同じビットマップが再度要求されたときに既存のオブジェクト

# を返すようになっています。

#==============================================================================



module Cache

  #--------------------------------------------------------------------------

  # ○ ネームウィンドウ用ビットマップの取得

  #--------------------------------------------------------------------------

  def self.name_bitmap(name)

    return load_name_bitmap(name)

  end

  #--------------------------------------------------------------------------

  # ○ 名前bitmapの作成

  #--------------------------------------------------------------------------

  def self.load_name_bitmap(name)

    @cache ||= {}

    key = [name, "name_window"]

    return @cache[key] if include?(key)

    

    # 計算用ダミービットマップ

    bitmap = Cache.system("")

    bitmap.font.name = A1_System::NameWindow::NAME_FONT

    bitmap.font.size = 16

    tw = bitmap.text_size(name).width + 8

    

    # ビットマップ作成

    bitmap = Bitmap.new(tw, bitmap.font.size + 4)

    bitmap.font.name = A1_System::NameWindow::NAME_FONT

    bitmap.font.size = 16

    bitmap.font.color = Color.new(255,255,255)

    bitmap.draw_text(0, 0, bitmap.width, bitmap.height, name, 1)

    

    @cache[key] = bitmap

    return @cache[key]

  end

end

#==============================================================================

# ■ Window_FaceName

#==============================================================================



class Window_FaceName < Window_Base

  #--------------------------------------------------------------------------

  # ○ オブジェクト初期化

  #--------------------------------------------------------------------------

  def initialize(name, z)

    info = create_name_sprite(name)

    super(0, 0, info[0], info[1])

    self.visible = true

    self.openness = 0

    self.z = z

    skin = Cache.system("Window").clone

    skin.clear_rect(80, 16, 32, 32)

    self.windowskin = skin

    @name_sprite.z = self.z + 10

  end

  #--------------------------------------------------------------------------

  # ○ ネームウィンドウのセットアップ

  #--------------------------------------------------------------------------

  def setup_name_window(name)

    info = create_name_sprite(name)

    self.width  = info[0]

    self.height = info[1]

    create_contents

    @name_sprite.z = self.z + 10

  end

  #--------------------------------------------------------------------------

  # ○ フレーム更新

  #--------------------------------------------------------------------------

  def update

    super

    @name_sprite.visible = self.visible && self.open?

    return unless self.open?

    @name_sprite.update

  end

  #--------------------------------------------------------------------------

  # ○ 解放

  #--------------------------------------------------------------------------

  def dispose

    @name_sprite.bitmap.dispose

    @name_sprite.dispose

    super

  end

  #--------------------------------------------------------------------------

  # ○ ウィンドウを開く

  #--------------------------------------------------------------------------

  def open

    super

    @name_sprite.x = self.x + self.width / 2

    @name_sprite.y = self.y + self.height / 2

  end

  #--------------------------------------------------------------------------

  # ○ スプライトの作成

  #--------------------------------------------------------------------------

  def create_name_sprite(name)

    # ビットマップの取得

    bitmap = Cache.name_bitmRozszpunka

    

    # スプライト設定

    @name_sprite         = Sprite.new

    @name_sprite.bitmap  = bitmap

    @name_sprite.ox      = bitmap.width / 2

    @name_sprite.oy      = bitmap.height / 2

    @name_sprite.visible = false

    

    return [bitmap.width + 8, bitmap.height + 8]

  end

end

#==============================================================================

# ■ Window_Base

#------------------------------------------------------------------------------

# 　ゲーム中のすべてのウィンドウのスーパークラスです。

#==============================================================================



class Window_Base < Window

  #--------------------------------------------------------------------------

  # ☆ オブジェクト初期化

  #--------------------------------------------------------------------------

  alias a1_name_window_window_base_initialize initialize 

  def initialize(x, y, width, height)

    a1_name_window_window_base_initialize(x, y, width, height)

    create_name_window

  end

  #--------------------------------------------------------------------------

  # ☆ フレーム更新

  #--------------------------------------------------------------------------

  alias a1_name_window_window_base_update update 

  def update

    a1_name_window_window_base_update

    update_name_window

  end

  #--------------------------------------------------------------------------

  # ☆ 顔グラフィックの描画

  #--------------------------------------------------------------------------

  alias a1_name_window_window_base_draw_face draw_face

  def draw_face(face_name, face_index, x, y, size = 96)

    a1_name_window_window_base_draw_face(face_name, face_index, x, y, size)

    show_name_window(face_name, face_index, x, size)

  end

  #--------------------------------------------------------------------------

  # ☆ ウィンドウを閉じる

  #--------------------------------------------------------------------------

  alias a1_name_window_window_base_close close

  def close

    a1_name_window_window_base_close

  end

  #--------------------------------------------------------------------------

  # ☆ 解放

  #--------------------------------------------------------------------------

  alias a1_name_window_window_base_dispose dispose

  def dispose

    a1_name_window_window_base_dispose

    dispose_name_window

  end

  #--------------------------------------------------------------------------

  # ○ ネームウィンドウの解放

  #--------------------------------------------------------------------------

  def dispose_name_window

    @name_windows.values.each {|window| window.dispose }

  end

  #--------------------------------------------------------------------------

  # ○ ネームウィンドウの更新

  #--------------------------------------------------------------------------

  def update_name_window

    @name_windows.values.each {|window| window.update }

  end

  #--------------------------------------------------------------------------

  # ○ ネームウィンドウを使用？

  #--------------------------------------------------------------------------

  def use_name_window?

    A1_System::NameWindow::USE_NAME_WINDOW_CLASS.each {|clas| return true if self.is_a?(clas) }

    return false

  end

  #--------------------------------------------------------------------------

  # ○ ネームウィンドウの作成

  #--------------------------------------------------------------------------

  def create_name_window

    @name_windows = {}

  end

  #--------------------------------------------------------------------------

  # ○ 表示する名前の取得

  #--------------------------------------------------------------------------

  def show_name(face_name, face_index)

    return nil unless $game_system.use_name_window

    name = $game_temp.direct_show_name

    if name.empty?

      return nil if face_name == nil || face_name.empty?

      name = A1_System::NameWindow::NAME_LIST[sprintf("%s_%d", face_name, face_index)]

      name = A1_System::NameWindow::NAME_LIST[face_name] if name == nil

      name = name[$game_temp.name_index] if name.is_a?(Array)

      name = $game_actors[$1.to_i].name if name =~ /Actor\[(\d+)\]/

    end

    $game_temp.name_index       = 0

    $game_temp.direct_show_name = ""

    return name

  end

  #--------------------------------------------------------------------------

  # ○ ネームウィンドウの表示

  #--------------------------------------------------------------------------

  def show_name_window(face_name, face_index, x, size = 96)

    return unless use_name_window?

    name = show_name(face_name, face_index)

    return if name == nil or name.empty?

    if name == "祈り主"

      name = "Prayer Master"

    end

    if name == "色情魔サティロス"

      name = "Lust Demon Satyr"

    end

    if name == "フェアリーA"

      name = "Fairy A"

    end

    if name == "フェアリーB"

      name = "Fairy B"

    end

    if name == "フェアリーC"

      name = "Fairy C"

    end

    if name == "黒の尖兵リンダメア"

      name = "Black Vanguard Lindamea"

    end

    if name == "黒の審判者ハイン"

      name = "Black Arbiter Hein"

    end

    if name == "黒の教戒師エズワルド"

      name = "Black Chaplain Ezwald"

    end

    if name == "死体"

      name = "Corpse"

    end

    if name == "貴婦人"

      name = "Lady"

    end

    if name == "貴族"

      name = "Aristocrat"

    end

    if name == "教徒"

      name = "Believer"

    end

    if name == "国民"

      name = "People"

    end

    if name == "邪神"

      name = "Evil God"

    end

    if name == "子供"

      name = "Child"

    end

    if name == "喋る花"

      name = "Talking Flower"

    end

    if name == "心折れた勇者"

      name = "Crestfallen Hero"

    end

    if name == "亀騎士アダマン"

      name = "Tortoise Knight Adaman"

    end

    if name == "兎騎士ルミラージ"

      name = "Hare Knight L-Mi'raj"

    end

    if name == "ヘンゼル"

      name = "Hansel"

    end

    if name == "グレーテル"

      name = "Gretel"

    end

    if name == "飢餓のハイエナ"

      name = "Hyena of Hunger"

    end

    if name == "鉄の王様"

      name = "Iron King"

    end

    if name == "裸の王様"

      name = "Naked King"

    end

    if name == "ハーメルンの笛吹き男"

      name = "Pied Piper of Elixir"

    end

    if name == "醜いアヒルの子"

      name = "Ugly Duckling"

    end

    if name == "ジャック"

      name = "Jack"

    end

    if name == "ピーター・パン"

      name = "Peter Pan"

    end

    if name == "王者シンドバッド"

      name = "King Sinbad"

    end

    if name == "ロバの王様"

      name = "Donkey King"

    end

    if name == "マッチ売りの少女"

      name = "Little Match Girl"

    end

    if name == "パトラッシュ"

      name = "Patrasche"

    end

    if name == "カエルのお姫様"

      name = "Princess Frog"

    end

    if name == "髪長姫ラプンツェル"

      name = "Hair Princess Rapunzel"

    end

    if name == "小人"

      name = "Gnome"

    end

    if name == "白雪姫"

      name = "Snow White"

    end

    if name == "人魚姫"

      name = "Little Mermaid"

    end

    if name == "シンデレラ"

      name = "Cinderella"

    end

    if name == "エリザベート・バートリー"

      name = "Elisabeth Bathory"

    end

    if name == "心失くしのブリキ"

      name = "Heartless Tin Man"

    end

    if name == "臆病なライオン"

      name = "Cowardly Lion"

    end

    if name == "知恵遅れの案山子"

      name = "Moronic Scarecrow"

    end

    if name == "ラミア"

      name = "Lamia"

    end

    if name == "鍛冶屋ロプス"

      name = "Blacksmith Lops"

    end

    if name == "堕落した賢者"

      name = "Corrupted Sage"

    end

    if name == "白雪の王子"

      name = "Snow White's Prince"

    end

    if name == "傀儡子ピノッキオ"

      name = "Marionette Boy Pinocchio"

    end

    if name == "人形"

      name = "Puppet"

    end

    if name == "聖女の護衛オックス"

      name = "Saint's Guardian Ox"

    end

    if name == "聖女の護衛ベリオール"

      name = "Saint's Guardian Belior"

    end

    if name == "聖女カタリナ"

      name = "Saint Catherine"

    end

    if name == "守護のカメレオン"

      name = "Guardian Chameleon"

    end

    if name == "混沌の魔女ドロシー"

      name = "Chaos Witch Dorothy"

    end

    if name == "放浪騎士イズ"

      name = "Wandering Knight Izu"

    end

    if name == "黄金のガチョウ"

      name = "Golden Goose"

    end

    if name == "聖獣ジャンヌ・ダルク"

      name = "Holy Beast Jeanne d'Arc"

    end

    if name == "淫魔獣ヴィクトリア"

      name = "Demon of Desire Victoria"

    end

    if name == "メアリィ・スー"

      name = "Mary Sue"

    end

    if name == "陰月の騎士オーエンティウス"

      name = "Shadowmoon Knight Oentius"

    end

    if name == "罪背負いのヴィルト"

      name = "Sinner Wilt"

    end

    if name == "時計鰐"

      name = "Clock Croc"

    end

    if name == "魔獣ヴィルト"

      name = "Demonbeast Wilt"

    end

    if name == "愚かな王子"

      name = "Foolish Prince"

    end

    if name == "退廃主"

      name = "Lord of Corruption"

    end

    if name == "ヴァンパイア"

      name = "Vampire"

    end

    if name == "立ち直った勇者"

      name = "Hopeful Hero"

    end

    if name == "盗賊"

      name = "Thief"

    end

    if name == "教戒師エズワルド"

      name = "Chaplain Ezwald"

    end

    if name == "名も無き商人"

      name = "Nameless Trader"

    end

    if name == "猫"

      name = "Cat"

    end

    if name == "売春婦"

      name = "Prostitute"

    end

    if name == "犬"

      name = "Dog"

    end

    if name == "死んだ眼をしている男性"

      name = "Resigned Man"

    end

    if name == "男主"

      name = "Master"

    end

    if name == "街の兵士"

      name = "Garrison Soldier"

    end

    if name == "エルマの母"

      name = "Elma's Mother"

    end

    if name == "使用人"

      name = "Servant"

    end

    if name == "リリス"

      name = "Lilith"

    end

    if name == "死にかけの戦士"

      name = "Dying Warrior"

    end

    if name == "喋るラフレシア"

      name = "Talking Rafflesia"

    end

    if name == "兎"

      name = "Rabbit"

    end

    if name == "熊"

      name = "Bear"

    end

    if name == "バンダースナッチ"

      name = "Bandersnatch"

    end

    if name == "老人"

      name = "Old Man"

    end

    if name == "ネロ"

      name = "Nello"

    end

    if name == "呪術師ケト"

      name = "Shaman Keto"

    end

    if name == "罪作りなドナル"

      name = "Sinful Donell"

    end

    if name == "カエル"

      name = "Frog"

    end

    if name == "カエルのハインリヒ"

      name = "Frog Heinrich"

    end

    if name == "お人好しのエリン"

      name = "Softy Erin"

    end

    if name == "女"

      name = "Woman"

    end

    if name == "？？？"

      name = "???"

    end

    @name_windows[name] ||= Window_FaceName.new(name, self.z + 10)

    if x <= Graphics.width / 2

      @name_windows[name].x = x + size + 20

      @name_windows[name].x = 0 if @name_windows[name].x + @name_windows[name].width > Graphics.width / 2 and A1_System::NameWindow::FIX_LONG_NAME

    else

      @name_windows[name].x = Graphics.width - size - @name_windows[name].width 

      @name_windows[name].x = Graphics.width - @name_windows[name].width if @name_windows[name].x < Graphics.width / 2 and A1_System::NameWindow::FIX_LONG_NAME

    end

    @name_windows[name].y = self.y      - 16 if self.y  > 0

    @name_windows[name].y = self.height - 16 if self.y == 0

    @name_windows[name].openness = 255 if self.open?

    @name_windows[name].open

    @name_windows[name].visible = true

  end

  #--------------------------------------------------------------------------

  # ○ ネームウィンドウを閉じる

  #--------------------------------------------------------------------------

  def name_window_close

    @name_windows.values.each {|window| window.close }

  end

  #--------------------------------------------------------------------------

  # ○ ネームウィンドウを非表示

  #--------------------------------------------------------------------------

  def name_window_visible_false

    @name_windows.values.each {|window| window.visible = false }

  end

end

#==============================================================================

# ■ Window_Message

#------------------------------------------------------------------------------

# 　文章表示に使うメッセージウィンドウです。

#==============================================================================



class Window_Message

  #--------------------------------------------------------------------------

  # ○ ウィンドウを閉じる

  #--------------------------------------------------------------------------

  def close

    name_window_close

    super

  end

end

#==============================================================================

# ◆ RGSS3用処理

#==============================================================================

if rgss_version == 3

#==============================================================================

# ■ Window_Message

#------------------------------------------------------------------------------

# 　文章表示に使うメッセージウィンドウです。

#==============================================================================



class Window_Message < Window_Base

  #--------------------------------------------------------------------------

  # ☆ 改ページ処理

  #--------------------------------------------------------------------------

  alias a1_name_window_window_message_new_page new_page 

  def new_page(text, pos)

    name_window_visible_false

    a1_name_window_window_message_new_page(text, pos)

  end

end

#==============================================================================

# ◆ RGSS2用処理

#==============================================================================

elsif rgss_version == 2

#==============================================================================

# ■ Window_Message

#------------------------------------------------------------------------------

# 　文章表示に使うメッセージウィンドウです。

#==============================================================================



class Window_Message < Window_Selectable

  #--------------------------------------------------------------------------

  # ☆ 改ページ処理

  #--------------------------------------------------------------------------

  alias a1_name_window_window_message_new_page new_page 

  def new_page

    name_window_visible_false

    a1_name_window_window_message_new_page

  end

end

#==============================================================================

# ◆ RGSS用処理

#==============================================================================

elsif rgss_version == 1

end

#==============================================================================

# ■ Game_System

#------------------------------------------------------------------------------

# 　システム周りのデータを扱うクラスです。乗り物や BGM などの管理も行います。

# このクラスのインスタンスは $game_system で参照されます。

#==============================================================================



class Game_System

  #--------------------------------------------------------------------------

  # ○ 公開インスタンス変数

  #--------------------------------------------------------------------------

  attr_accessor :use_name_window                # ネームウィンドウ表示フラグ

  #--------------------------------------------------------------------------

  # ☆ オブジェクト初期化

  #--------------------------------------------------------------------------

  alias a1_name_window_game_system_initialize initialize

  def initialize

    a1_name_window_game_system_initialize

    @use_name_window = false

  end

end

#==============================================================================

# ■ Game_Temp

#------------------------------------------------------------------------------

# 　セーブデータに含まれない、一時的なデータを扱うクラスです。このクラスのイン

# スタンスは $game_temp で参照されます。

#==============================================================================



class Game_Temp

  #--------------------------------------------------------------------------

  # ○ 公開インスタンス変数

  #--------------------------------------------------------------------------

  attr_accessor :name_index

  attr_accessor :direct_show_name

  #--------------------------------------------------------------------------

  # ☆ オブジェクト初期化

  #--------------------------------------------------------------------------

  alias a1_name_window_gt_initialize initialize

  def initialize

    a1_name_window_gt_initialize

    @name_index       = 0

    @direct_show_name = ""

  end

end

#==============================================================================

# ■ A1_System::CommonModule

#==============================================================================



class A1_System::CommonModule

  #--------------------------------------------------------------------------

  # ☆ 注釈コマンド定義

  #--------------------------------------------------------------------------

  alias a1_name_window_define_command define_command

  def define_command

    a1_name_window_define_command

    @cmd_108["ネームウィンドウ"] = :name_window

    @cmd_108["NWインデックス"]   = :nw_index

    @cmd_108["NW名前指定"]       = :nw_set_name

  end

end

#==============================================================================

# ■ Game_Interpreter

#------------------------------------------------------------------------------

# 　イベントコマンドを実行するインタプリタです。このクラスは Game_Map クラス、

# Game_Troop クラス、Game_Event クラスの内部で使用されます。

#==============================================================================



class Game_Interpreter

  #--------------------------------------------------------------------------

  # ○ ネームウィンドウ

  #--------------------------------------------------------------------------

  def name_window(params)

    $game_system.use_name_window = params[0] == "on" ? true : false

  end

  #--------------------------------------------------------------------------

  # ○ NWインデックス

  #--------------------------------------------------------------------------

  def nw_index(params)

    $game_temp.name_index = params[0].to_i

  end

  #--------------------------------------------------------------------------

  # ○ NW名前指定

  #--------------------------------------------------------------------------

  def nw_set_name(params)

    $game_temp.direct_show_name = params[0]

  end

end

end