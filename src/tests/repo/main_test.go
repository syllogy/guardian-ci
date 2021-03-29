package main_test

import (
	"testing"

	m "github.com/BishopFox/ignored_test_repo"
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

func TestThis(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "Test Suite")
}

var _ = Describe("DoIt", func() {
	It("should succeed", func() {
		Expect(m.DoIt()).To(BeTrue())
	})
})
