// 电池收纳盒：圆柱插孔式
// 7号(AAA): D10.5 L44
//
// 尺寸/体积/重量不再手写：渲染(F5)或导出时自动打到控制台，
// 改任意参数后数字自动同步，不会再出现注释与模型对不上的情况。

// ===== 电池参数 =====
batt_d = 10.5;      // 电池直径
batt_l = 44.0;      // 电池长度（用于核对露出高度）

// ===== 结构参数 =====
clearance = 0.8;    // 孔间隙（直径方向，单边 0.4）
hole_d = batt_d + clearance;   // 圆柱孔直径
hole_deep = 24;     // 孔深（电池插入深度）
pierce = 0.5;       // 孔柱顶部额外的穿透量（避免孔顶面与盒顶面共面 → 预览/切片伪影）
bottom = 2.5;       // 底部厚度
wall = 2.5;         // 外壁厚
pitch = hole_d + 2; // 孔中心距（孔间壁厚 = 2.0）
cols = 5;           // 列数
rows = 5;           // 行数
corner_r = 3.0;     // 外轮廓四角圆角半径，0 = 直角

// ===== 网格精度 =====
// 分开控制：改孔的精度不会连带改变圆角，反之亦然（原先全局 $fn 把两者耦合在一起）。
hole_fn = 48;       // 每个圆柱孔的分段数
corner_fn = 48;     // 圆角圆弧的分段数（按整圆计）

// ===== 材料参数 =====
density = 1.24;     // g/cm³：PLA 1.24 / PETG 1.27 / ABS 1.04

// ===== 推导尺寸 =====
outer_l = pitch*(cols-1) + hole_d + 2*wall;  // 外廓长
outer_w = pitch*(rows-1) + hole_d + 2*wall;  // 外廓宽
h = bottom + hole_deep;                      // 盒高
hole_r = hole_d/2;
hole_count = cols*rows;
exposed_l = batt_l - hole_deep;              // 电池露出高度

assert(clearance >= 0, "clearance 为负会让孔径小于电池");
assert(corner_r >= 0 && corner_r < min(outer_l, outer_w)/2 - wall,
       "corner_r 超出范围，圆角会切穿外壁");
// 原先这里是 assert(hole_deep < h)，但 h = bottom + hole_deep，
// 该条件等价于 0 < bottom，永远成立，拦不住任何误操作。换成真正会出错的三项：
assert(bottom > 0, "bottom 必须为正，否则孔会打穿盒底");
assert(hole_deep > 0, "hole_deep 必须为正");
assert(cols >= 1 && rows >= 1, "cols/rows 至少为 1");
assert(hole_fn >= 3 && corner_fn >= 3, "hole_fn/corner_fn 至少为 3，否则多边形退化");

// ===== 体积与重量（解析计算）=====
// OpenSCAD 没有测网格体积的内置函数，这里按公式算解析值。
// 孔按 cylinder 实际生成的内接正 hole_fn 边形算，与 STL 实测同源，不需要再挂「约高 0.3%」的免责注释。
corner_cut = (4 - PI) * corner_r * corner_r;         // 圆角相对直角的面积损失
gross_vol = (outer_l*outer_w - corner_cut) * h;      // mm³
hole_area = 0.5 * hole_fn * hole_r * hole_r * sin(360 / hole_fn);  // 内接多边形面积
hole_vol = hole_count * hole_area * hole_deep;
net_vol = gross_vol - hole_vol;                      // mm³

function fmt(x, n) = round(x * pow(10, n)) / pow(10, n);

echo(str("外廓 : ", fmt(outer_l,2), " × ", fmt(outer_w,2), " × ", fmt(h,2), " mm"));
echo(str("孔   : ", hole_count, " 个 Ø", fmt(hole_d,2), " × 深 ", fmt(hole_deep,2),
         " mm；电池露出 ", fmt(exposed_l,1), " mm"));
echo(str("体积 : ", fmt(net_vol/1000,2), " cm³（理论值）"));
echo(str("重量 : ", fmt(net_vol/1000*density,1), " g（实心等效，15% 填充实际约省 15-25%）"));

// ===== 几何 =====
module rounded_rect(w, d, r) {
    if (r > 0) offset(r = r, $fn = corner_fn) offset(delta = -r) square([w, d]);
    else square([w, d]);
}

module hole_grid() {
    for(c=[0:cols-1], r=[0:rows-1]){
        translate([wall + hole_r + c*pitch,
                   wall + hole_r + r*pitch,
                   bottom])
        cylinder(h=hole_deep + pierce, d=hole_d, $fn = hole_fn);
    }
}

module batt_box(){
    difference(){
        // 圆角盒体
        linear_extrude(height = h)
            rounded_rect(outer_l, outer_w, corner_r);
        // 挖圆柱电池孔
        hole_grid();
    }
}

batt_box();
