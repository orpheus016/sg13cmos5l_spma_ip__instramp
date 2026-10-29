import pya

ly = pya.Layout()
ly.read("gds/pgia_top/pgia_top.gds")
c_pgia = ly.cell("pgia_top")

print("=== Instances in pgia_top ===")
inst_boxes = []
for inst in c_pgia.each_inst():
    c_sub = inst.cell
    trans = inst.trans
    bbox = c_sub.bbox().transformed(trans)
    print(f"Cell {c_sub.name:16s} at {trans.to_s()} -> Bbox: ({bbox.left*1e-3:.3f}, {bbox.bottom*1e-3:.3f}) to ({bbox.right*1e-3:.3f}, {bbox.top*1e-3:.3f}) um")
    inst_boxes.append((c_sub.name, bbox))

# Check for overlaps between instance bboxes
print("\n=== Instance Bbox Overlaps ===")
for i in range(len(inst_boxes)):
    for j in range(i + 1, len(inst_boxes)):
        name1, b1 = inst_boxes[i]
        name2, b2 = inst_boxes[j]
        inter = b1 & b2
        if not inter.is_empty():
            print(f"OVERLAP between {name1} and {name2}: ({inter.left*1e-3:.3f}, {inter.bottom*1e-3:.3f}) to ({inter.right*1e-3:.3f}, {inter.top*1e-3:.3f}) um")
        else:
            print(f"Clear: {name1} and {name2}")

