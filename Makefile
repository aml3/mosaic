

display: display.ml
	ocamlc graphics.cma unix.cma types.ml display.ml

clean:
	rm a.out *.cmi *.cmo
