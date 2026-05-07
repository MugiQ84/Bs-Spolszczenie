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

#==============================================================================

$imported ||= {}

$imported["A1 Name Window"] = true

if $imported["A1 Common Script"]

old common script("ネームウィンドウ", "3.30") if common version < 3.30

#==============================================================================

# ■ 設定項目

#==============================================================================

module A1 System::NameWindow



  #--------------------------------------------------------------------------

  # ネームウィンドウを使用するクラス

  #--------------------------------------------------------------------------

  USE NAME WINDOW CLASS = [Window Message]

  

  #--------------------------------------------------------------------------

  # ネームウィンドウのフォント

  #--------------------------------------------------------------------------

  NAME FONT = "UmePlus Gothic"

  

  #--------------------------------------------------------------------------

  # 長い名前の時に左(右)に寄せる

  #--------------------------------------------------------------------------

  FIX LONG NAME = false

  

  #--------------------------------------------------------------------------

  # 顔グラフィックと名前の対応

  #

  #  "[ファイル名] [Index]" => "表示する名前" ※Index毎に設定

  #  "[ファイル名]"         => "表示する名前" ※該当ファイル全てに適用

  #                            "Actor[ID]"    ※該当するIDのアクター名を表示

  #--------------------------------------------------------------------------

  NAME LIST = {

    "aka"    => "Czerwony Kapturek",

    "ri-hu"    => "Czarodziejka Leaf",

    "alice"    => "Alicja",

    "alice2"    => "Alicja",

    "jnnu"    => "Rycerz Joanna",

    "doro"    => "Czarownica Dorota",

    "eriza"    => "Dama Dusz Elżbieta",

    "eruma"    => "Elma Sprzedawczyni Zapałek",

    "beru"    => "Piękna Belle",

    "biku"    => "Pokojówka Wiktoria",

    "gu-su"    => "Bogata Gęś Goose",

    "kata"    => "Święta Katarina",

    "miranda"    => "Mroczna Miranda",

    "kaeru"    => "Księżniczka Żaba",

    "nin"    => "Syrena",

    "lap"    => "Roszpunka",

    "sira"    => "Królewna Śnieżka",

    "sin"    => "Kopciuszek",

    "poro"    => "Poro",

    "ri-hu2"    => "Mary Sue",

    "maria"    => "Marianna",

    "hen"    => "Jaś",

    "gure"    => "Małgosia",

    "ba"    => "Mroczny Sędzia Baphomet",

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

  def self.name bitmap(name)

    return load name bitmap(name)

  end

  #--------------------------------------------------------------------------

  # ○ 名前bitmapの作成

  #--------------------------------------------------------------------------

  def self.load name bitmap(name)

    @cache ||= {}

    key = [name, "name window"]

    return @cache[key] if include?(key)

    

    # 計算用ダミービットマップ

    bitmap = Cache.system("")

    bitmap.font.name = A1 System::NameWindow::NAME FONT

    bitmap.font.size = 16

    tw = bitmap.text size(name).width + 8

    

    # ビットマップ作成

    bitmap = Bitmap.new(tw, bitmap.font.size + 4)

    bitmap.font.name = A1 System::NameWindow::NAME FONT

    bitmap.font.size = 16

    bitmap.font.color = Color.new(255,255,255)

    bitmap.draw text(0, 0, bitmap.width, bitmap.height, name, 1)

    

    @cache[key] = bitmap

    return @cache[key]

  end

end

#==============================================================================

# ■ Window FaceName

#==============================================================================



class Window FaceName < Window Base

  #--------------------------------------------------------------------------

  # ○ オブジェクト初期化

  #--------------------------------------------------------------------------

  def initialize(name, z)

    info = create name sprite(name)

    super(0, 0, info[0], info[1])

    self.visible = true

    self.openness = 0

    self.z = z

    skin = Cache.system("Window").clone

    skin.clear rect(80, 16, 32, 32)

    self.windowskin = skin

    @name sprite.z = self.z + 10

  end

  #--------------------------------------------------------------------------

  # ○ ネームウィンドウのセットアップ

  #--------------------------------------------------------------------------

  def setup name window(name)

    info = create name sprite(name)

    self.width  = info[0]

    self.height = info[1]

    create contents

    @name sprite.z = self.z + 10

  end

  #--------------------------------------------------------------------------

  # ○ フレーム更新

  #--------------------------------------------------------------------------

  def update

    super

    @name sprite.visible = self.visible && self.open?

    return unless self.open?

    @name sprite.update

  end

  #--------------------------------------------------------------------------

  # ○ 解放

  #--------------------------------------------------------------------------

  def dispose

    @name sprite.bitmap.dispose

    @name sprite.dispose

    super

  end

  #--------------------------------------------------------------------------

  # ○ ウィンドウを開く

  #--------------------------------------------------------------------------

  def open

    super

    @name sprite.x = self.x + self.width / 2

    @name sprite.y = self.y + self.height / 2

  end

  #--------------------------------------------------------------------------

  # ○ スプライトの作成

  #--------------------------------------------------------------------------

  def create name sprite(name)

    # ビットマップの取得

    bitmap = Cache.name bitmap(name)

    

    # スプライト設定

    @name sprite         = Sprite.new

    @name sprite.bitmap  = bitmap

    @name sprite.ox      = bitmap.width / 2

    @name sprite.oy      = bitmap.height / 2

    @name sprite.visible = false

    

    return [bitmap.width + 8, bitmap.height + 8]

  end

end

#==============================================================================

# ■ Window Base

#------------------------------------------------------------------------------

# 　ゲーム中のすべてのウィンドウのスーパークラスです。

#==============================================================================



class Window Base < Window

  #--------------------------------------------------------------------------

  # ☆ オブジェクト初期化

  #--------------------------------------------------------------------------

  alias a1 name window window base initialize initialize 

  def initialize(x, y, width, height)

    a1 name window window base initialize(x, y, width, height)

    create name window

  end

  #--------------------------------------------------------------------------

  # ☆ フレーム更新

  #--------------------------------------------------------------------------

  alias a1 name window window base update update 

  def update

    a1 name window window base update

    update name window

  end

  #--------------------------------------------------------------------------

  # ☆ 顔グラフィックの描画

  #--------------------------------------------------------------------------

  alias a1 name window window base draw face draw face

  def draw face(face name, face index, x, y, size = 96)

    a1 name window window base draw face(face name, face index, x, y, size)

    show name window(face name, face index, x, size)

  end

  #--------------------------------------------------------------------------

  # ☆ ウィンドウを閉じる

  #--------------------------------------------------------------------------

  alias a1 name window window base close close

  def close

    a1 name window window base close

  end

  #--------------------------------------------------------------------------

  # ☆ 解放

  #--------------------------------------------------------------------------

  alias a1 name window window base dispose dispose

  def dispose

    a1 name window window base dispose

    dispose name window

  end

  #--------------------------------------------------------------------------

  # ○ ネームウィンドウの解放

  #--------------------------------------------------------------------------

  def dispose name window

    @name windows.values.each {|window| window.dispose }

  end

  #--------------------------------------------------------------------------

  # ○ ネームウィンドウの更新

  #--------------------------------------------------------------------------

  def update name window

    @name windows.values.each {|window| window.update }

  end

  #--------------------------------------------------------------------------

  # ○ ネームウィンドウを使用？

  #--------------------------------------------------------------------------

  def use name window?

    A1 System::NameWindow::USE NAME WINDOW CLASS.each {|clas| return true if self.is a?(clas) }

    return false

  end

  #--------------------------------------------------------------------------

  # ○ ネームウィンドウの作成

  #--------------------------------------------------------------------------

  def create name window

    @name windows = {}

  end

  #--------------------------------------------------------------------------

  # ○ 表示する名前の取得

  #--------------------------------------------------------------------------

  def show name(face name, face index)

    return nil unless $game system.use name window

    name = $game temp.direct show name

    if name.empty?

      return nil if face name == nil || face name.empty?

      name = A1 System::NameWindow::NAME LIST[sprintf("%s %d", face name, face index)]

      name = A1 System::NameWindow::NAME LIST[face name] if name == nil

      name = name[$game temp.name index] if name.is a?(Array)

      name = $game actors[$1.to i].name if name =~ /Actor\[(\d+)\]/

    end

    $game temp.name index       = 0

    $game temp.direct show name = ""

    return name

  end

  #--------------------------------------------------------------------------

  # ○ ネームウィンドウの表示

  #--------------------------------------------------------------------------

  def show name window(face name, face index, x, size = 96)

    return unless use name window?

    name = show name(face name, face index)

    return if name == nil or name.empty?

    @name windows[name] ||= Window FaceName.new(name, self.z + 10)

    if x <= Graphics.width / 2

      @name windows[name].x = x + size + 20

      @name windows[name].x = 0 if @name windows[name].x + @name windows[name].width > Graphics.width / 2 and A1 System::NameWindow::FIX LONG NAME

    else

      @name windows[name].x = Graphics.width - size - @name windows[name].width 

      @name windows[name].x = Graphics.width - @name windows[name].width if @name windows[name].x < Graphics.width / 2 and A1 System::NameWindow::FIX LONG NAME

    end

    @name windows[name].y = self.y      - 16 if self.y  > 0

    @name windows[name].y = self.height - 16 if self.y == 0

    @name windows[name].openness = 255 if self.open?

    @name windows[name].open

    @name windows[name].visible = true

  end

  #--------------------------------------------------------------------------

  # ○ ネームウィンドウを閉じる

  #--------------------------------------------------------------------------

  def name window close

    @name windows.values.each {|window| window.close }

  end

  #--------------------------------------------------------------------------

  # ○ ネームウィンドウを非表示

  #--------------------------------------------------------------------------

  def name window visible false

    @name windows.values.each {|window| window.visible = false }

  end

end

#==============================================================================

# ■ Window Message

#------------------------------------------------------------------------------

# 　文章表示に使うメッセージウィンドウです。

#==============================================================================



class Window Message

  #--------------------------------------------------------------------------

  # ○ ウィンドウを閉じる

  #--------------------------------------------------------------------------

  def close

    name window close

    super

  end

end

#==============================================================================

# ◆ RGSS3用処理

#==============================================================================

if rgss version == 3

#==============================================================================

# ■ Window Message

#------------------------------------------------------------------------------

# 　文章表示に使うメッセージウィンドウです。

#==============================================================================



class Window Message < Window Base

  #--------------------------------------------------------------------------

  # ☆ 改ページ処理

  #--------------------------------------------------------------------------

  alias a1 name window window message new page new page 

  def new page(text, pos)

    name window visible false

    a1 name window window message new page(text, pos)

  end

end

#==============================================================================

# ◆ RGSS2用処理

#==============================================================================

elsif rgss version == 2

#==============================================================================

# ■ Window Message

#------------------------------------------------------------------------------

# 　文章表示に使うメッセージウィンドウです。

#==============================================================================



class Window Message < Window Selectable

  #--------------------------------------------------------------------------

  # ☆ 改ページ処理

  #--------------------------------------------------------------------------

  alias a1 name window window message new page new page 

  def new page

    name window visible false

    a1 name window window message new page

  end

end

#==============================================================================

# ◆ RGSS用処理

#==============================================================================

elsif rgss version == 1

end

#==============================================================================

# ■ Game System

#------------------------------------------------------------------------------

# 　システム周りのデータを扱うクラスです。乗り物や BGM などの管理も行います。

# このクラスのインスタンスは $game system で参照されます。

#==============================================================================



class Game System

  #--------------------------------------------------------------------------

  # ○ 公開インスタンス変数

  #--------------------------------------------------------------------------

  attr accessor :use name window                # ネームウィンドウ表示フラグ

  #--------------------------------------------------------------------------

  # ☆ オブジェクト初期化

  #--------------------------------------------------------------------------

  alias a1 name window game system initialize initialize

  def initialize

    a1 name window game system initialize

    @use name window = false

  end

end

#==============================================================================

# ■ Game Temp

#------------------------------------------------------------------------------

# 　セーブデータに含まれない、一時的なデータを扱うクラスです。このクラスのイン

# スタンスは $game temp で参照されます。

#==============================================================================



class Game Temp

  #--------------------------------------------------------------------------

  # ○ 公開インスタンス変数

  #--------------------------------------------------------------------------

  attr accessor :name index

  attr accessor :direct show name

  #--------------------------------------------------------------------------

  # ☆ オブジェクト初期化

  #--------------------------------------------------------------------------

  alias a1 name window gt initialize initialize

  def initialize

    a1 name window gt initialize

    @name index       = 0

    @direct show name = ""

  end

end

#==============================================================================

# ■ A1 System::CommonModule

#==============================================================================



class A1 System::CommonModule

  #--------------------------------------------------------------------------

  # ☆ 注釈コマンド定義

  #--------------------------------------------------------------------------

  alias a1 name window define command define command

  def define command

    a1 name window define command

    @cmd 108["ネームウィンドウ"] = :name window

    @cmd 108["NWインデックス"]   = :nw index

    @cmd 108["NW名前指定"]       = :nw set name

  end

end

#==============================================================================

# ■ Game Interpreter

#------------------------------------------------------------------------------

# 　イベントコマンドを実行するインタプリタです。このクラスは Game Map クラス、

# Game Troop クラス、Game Event クラスの内部で使用されます。

#==============================================================================



class Game Interpreter

  #--------------------------------------------------------------------------

  # ○ ネームウィンドウ

  #--------------------------------------------------------------------------

  def name window(params)

    $game system.use name window = params[0] == "on" ? true : false

  end

  #--------------------------------------------------------------------------

  # ○ NWインデックス

  #--------------------------------------------------------------------------

  def nw index(params)

    $game temp.name index = params[0].to i

  end

  #--------------------------------------------------------------------------

  # ○ NW名前指定

  #--------------------------------------------------------------------------

  def nw set name(params)

    $game temp.direct show name = params[0]

  end

end

end