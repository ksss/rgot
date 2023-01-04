package t_test

import (
	"testing"
)

func Foo(i int, s string) (string, error) {
	return "", nil
}

func FuzzPass(f *testing.F) {
	f.Add(5, "hello")
	f.Fuzz(func(t *testing.T, i int, s string) {
		// t.Error("fuzz!")
	})
}

func FuzzFail(f *testing.F) {
	f.Add(5, "hello")
	f.Fuzz(func(t *testing.T, i int, s string) {
		// t.Error("fuzz!")
	})
}
