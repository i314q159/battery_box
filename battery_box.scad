$fn=48;
// 电池收纳盒：圆柱插孔式
// 7号(AAA): D10.5 L44

// ===== 电池参数 =====
batt_d = 10.5;      // 电池直径
batt_l = 44.0;      // 电池长度

// ===== 结构参数 =====
clearance = 0.8;    // 孔间隙
hole_d = batt_d + clearance;   // 圆柱孔直径
hole_deep = 24;     // 孔深（电池插入深度）
bottom = 2.5;       // 底部厚度
wall = 2.5;         // 外壁厚
pitch = hole_d + 2; // 孔中心距
cols = 5;           // 列数
rows = 5;           // 行数

// 结果：尺寸69.5×69.5×26.5mm，实体约67.8cm³（<70上限），25节，约78g（<90g）

outer_l = pitch*(cols-1) + hole_d + 2*wall;  // 外廓长
outer_w = pitch*(rows-1) + hole_d + 2*wall;  // 外廓宽
h = bottom + hole_deep;                      // 盒高

module batt_box(){
    difference(){
        // 实心盒体
        cube([outer_l, outer_w, h]);
        // 挖圆柱电池孔
        for(c=[0:cols-1], r=[0:rows-1]){
            translate([wall + hole_d/2 + c*pitch,
                       wall + hole_d/2 + r*pitch,
                       bottom])
            cylinder(h=hole_deep, d=hole_d);
        }
    }
}

batt_box();
