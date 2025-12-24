---
authors:
- admin
date: 2020-11-22 09:00:00
image:
  filename: go-logo.png
tags:
- GoLearn
title: The Go Programming Language（8）- goroutine
---

---



# The Go Programming Language（8)

### 源码、PDF版、Markdown、xmind版下载链接

```
https://1tnt1.lanzous.com/b00o36ytc
```

密码：

```
1ch0
```

---



## ch8  Goroutines和Channels

### ch8.0   简介

- 并发程序指同时进行多个任务的程序，随着硬件的发展，并发程序变得越来越重要。

	- Web服务器会一次处理成千上万的请求。平板电脑和手机app在渲染用户画面同时还会后台执行各种计算任务和网络请求。

- 即使是传统的批处理问题——读取数据、计算、写输出，现在也会用并发来隐藏掉I/O的操作延迟以充分利用现代计算机设备的多个核心。计算机的性能每年都在以非线性的速度增长。
- Go语言中的并发程序可以用两种手段来实现

	- 本章讲解goroutine和channel，其支持“顺序通信进程”（communicating sequential processes）或被简称为CSP。
	- CSP是一种现代的并发编程模型，在这种编程模型中值会在不同的运行实例（goroutine）中传递，尽管大多数情况下仍然是被限制在单一实例中。
	- 第9章覆盖更为传统的并发模型：多线程共享内存，如果你在其它的主流语言中写过并发程序的话可能会更熟悉一些。第9章也会深入介绍一些并发程序带来的风险和陷阱。

- 尽管Go对并发的支持是众多强力特性之一，但跟踪调试并发程序还是很困难，在线性程序中形成的直觉往往还会使我们误入歧途。如果这是读者第一次接触并发，推荐稍微多花一些时间来思考这两个章节中的样例。

### ch8.1Goroutines

- 在Go语言中，每一个并发的执行单元叫作一个goroutine。设想这里的一个程序有两个函数，一个函数做计算，另一个输出结果，假设两个函数没有相互之间的调用关系。一个线性的程序会先调用其中的一个函数，然后再调用另一个。如果程序中包含多个goroutine，对两个函数的调用则可能发生在同一时刻。马上就会看到这样的一个程序。
- 如果你使用过操作系统或者其它语言提供的线程，那么你可以简单地把goroutine类比作一个线程，这样你就可以写出一些正确的程序了。goroutine和线程的本质区别会在9.8节中讲。
- 当一个程序启动时，其主函数即在一个单独的goroutine中运行，我们叫它main goroutine。新的goroutine会用go语句来创建。在语法上，go语句是一个普通的函数或方法调用前加上关键字go。go语句会使其语句中的函数在一个新创建的goroutine中运行。而go语句本身会迅速地完成。

  ```go
  f()    // call f(); wait for it to return
  go f() // create a new goroutine that calls f(); don't wait
  ```

- 下面的例子，main goroutine将计算菲波那契数列的第45个元素值。由于计算函数使用低效的递归，所以会运行相当长时间，在此期间我们想让用户看到一个可见的标识来表明程序依然在正常运行，所以来做一个动画的小图标：

  <u><i>gopl.io/ch8/spinner</i><u>
  
  ```go
  func main() {
  	go spinner(100 * time.Millisecond)
  	const n = 45
  	fibN := fib(n) // slow
  	fmt.Printf("\rFibonacci(%d) = %d\n", n, fibN)
  }
  
  func spinner(delay time.Duration) {
  	for {
  		for _, r := range `-\|/` {
  			fmt.Printf("\r%c", r)
  			time.Sleep(delay)
  		}
  	}
  }
  
  func fib(x int) int {
  	if x < 2 {
  		return x
  	}
  	return fib(x-1) + fib(x-2)
  }
  ```

	- 动画显示了几秒之后，fib(45)的调用成功地返回，并且打印结果：

	  ```
	  Fibonacci(45) = 1134903170
	  ```

- 然后主函数返回。主函数返回时，所有的goroutine都会被直接打断，程序退出。除了从主函数退出或者直接终止程序之外，没有其它的编程方法能够让一个goroutine来打断另一个的执行，但是之后可以看到一种方式来实现这个目的，通过goroutine之间的通信来让一个goroutine请求其它的goroutine，并让被请求的goroutine自行结束执行。
- 留意一下这里的两个独立的单元是如何进行组合的，spinning和菲波那契的计算。分别在独立的函数中，但两个函数会同时执行。

### ch8.2   示例：并发的Clock服务

- 网络编程是并发大显身手的一个领域，由于服务器是最典型的需要同时处理很多连接的程序，这些连接一般来自于彼此独立的客户端。
- 在本小节中，我们会讲解go语言的net包，这个包提供编写一个网络客户端或者服务器程序的基本组件，无论两者间通信是使用TCP、UDP或者Unix domain sockets。在第一章中我们使用过的net/http包里的方法，也算是net包的一部分。
- 我们的第一个例子是一个顺序执行的时钟服务器，它会每隔一秒钟将当前时间写到客户端：

  <u><i>gopl.io/ch8/clock1</i></u>
  
  ```go
  // Clock1 is a TCP server that periodically writes the time.
  package main
  
  import (
  	"io"
  	"log"
  	"net"
  	"time"
  )
  
  func main() {
  	listener, err := net.Listen("tcp", "localhost:8000")
  	if err != nil {
  		log.Fatal(err)
  	}
  
  	for {
  		conn, err := listener.Accept()
  		if err != nil {
  			log.Print(err) // e.g., connection aborted
  			continue
  		}
  		handleConn(conn) // handle one connection at a time
  	}
  }
  
  func handleConn(c net.Conn) {
  	defer c.Close()
  	for {
  		_, err := io.WriteString(c, time.Now().Format("15:04:05\n"))
  		if err != nil {
  			return // e.g., client disconnected
  		}
  		time.Sleep(1 * time.Second)
  	}
  }
  
  ```

	- Listen函数创建了一个net.Listener的对象，这个对象会监听一个网络端口上到来的连接，在这个例子里我们用的是TCP的localhost:8000端口。listener对象的Accept方法会直接阻塞，直到一个新的连接被创建，然后会返回一个net.Conn对象来表示这个连接。
	- handleConn函数会处理一个完整的客户端连接。在一个for死循环中，用time.Now()获取当前时刻，然后写到客户端。由于net.Conn实现了io.Writer接口，我们可以直接向其写入内容。这个死循环会一直执行，直到写入失败。最可能的原因是客户端主动断开连接。这种情况下handleConn函数会用defer调用关闭服务器侧的连接，然后返回到主函数，继续等待下一个连接请求。

- time.Time.Format方法提供了一种格式化日期和时间信息的方式。它的参数是一个格式化模板，标识如何来格式化时间，而这个格式化模板限定为Mon Jan 2 03:04:05PM 2006 UTC-0700。有8个部分（周几、月份、一个月的第几天……）。可以以任意的形式来组合前面这个模板；出现在模板中的部分会作为参考来对时间格式进行输出。

	- 在上面的例子中我们只用到了小时、分钟和秒。time包里定义了很多标准时间格式，比如time.RFC1123。在进行格式化的逆向操作time.Parse时，也会用到同样的策略。
	- 这是go语言和其它语言相比比较奇葩的一个地方。你需要记住格式化字符串是1月2日下午3点4分5秒零六年UTC-0700，而不像其它语言那样Y-m-d H:i:s一样，当然了这里可以用1234567的方式来记忆，倒是也不麻烦。
	- 为了连接例子里的服务器，我们需要一个客户端程序，比如netcat这个工具（nc命令），这个工具可以用来执行网络连接操作。

	  ```
	  $ go build gopl.io/ch8/clock1
	  $ ./clock1 &
	  $ nc localhost 8000
	  13:58:54
	  13:58:55
	  13:58:56
	  13:58:57
	  ^C
	  ```

	- 客户端将服务器发来的时间显示了出来，我们用Control+C来中断客户端的执行，在Unix系统上，你会看到^C这样的响应。如果你的系统没有装nc这个工具，你可以用telnet来实现同样的效果，或者也可以用我们下面的这个用go写的简单的telnet程序，用net.Dial就可以简单地创建一个TCP连接：

	  <u><i>gopl.io/ch8/netcat1</i></u>
	  
	  ```go
	  // Netcat1 is a read-only TCP client.
	  package main
	  
	  import (
	  	"io"
	  	"log"
	  	"net"
	  	"os"
	  )
	  
	  func main() {
	  	conn, err := net.Dial("tcp", "localhost:8000")
	  	if err != nil {
	  		log.Fatal(err)
	  	}
	  	defer conn.Close()
	  	mustCopy(os.Stdout, conn)
	  }
	  
	  func mustCopy(dst io.Writer, src io.Reader) {
	  	if _, err := io.Copy(dst, src); err != nil {
	  		log.Fatal(err)
	  	}
	  }
	  ```

	- 这个程序会从连接中读取数据，并将读到的内容写到标准输出中，直到遇到end of file的条件或者发生错误。mustCopy这个函数我们在本节的几个例子中都会用到。让我们同时运行两个客户端来进行一个测试，这里可以开两个终端窗口，下面左边的是其中的一个的输出，右边的是另一个的输出：

	  ```
	  $ go build gopl.io/ch8/netcat1
	  $ ./netcat1
	  13:58:54                               $ ./netcat1
	  13:58:55
	  13:58:56
	  ^C
	                                         13:58:57
	                                         13:58:58
	                                         13:58:59
	                                         ^C
	  $ killall clock1
	  ```

	- killall命令是一个Unix命令行工具，可以用给定的进程名来杀掉所有名字匹配的进程。

- 第二个客户端必须等待第一个客户端完成工作，这样服务端才能继续向后执行；因为我们这里的服务器程序同一时间只能处理一个客户端连接。我们这里对服务端程序做一点小改动，使其支持并发：在handleConn函数调用的地方增加go关键字，让每一次handleConn的调用都进入一个独立的goroutine。

  <u><i>gopl.io/ch8/clock2</i></u>
  
  ```go
  for {
  	conn, err := listener.Accept()
  	if err != nil {
  		log.Print(err) // e.g., connection aborted
  		continue
  	}
  	go handleConn(conn) // handle connections concurrently
  }
  
  ```

	- 现在多个客户端可以同时接收到时间了：

	  ```
	  $ go build gopl.io/ch8/clock2
	  $ ./clock2 &
	  $ go build gopl.io/ch8/netcat1
	  $ ./netcat1
	  14:02:54                               $ ./netcat1
	  14:02:55                               14:02:55
	  14:02:56                               14:02:56
	  14:02:57                               ^C
	  14:02:58
	  14:02:59                               $ ./netcat1
	  14:03:00                               14:03:00
	  14:03:01                               14:03:01
	  ^C                                     14:03:02
	                                         ^C
	  $ killall clock2
	  ```

### ch8.3   示例：并发的Echo服务

- clock服务器每一个连接都会起一个goroutine。在本节中我们会创建一个echo服务器，这个服务在每个连接中会有多个goroutine。大多数echo服务仅仅会返回他们读取到的内容，就像下面这个简单的handleConn函数所做的一样：

  ```go
  func handleConn(c net.Conn) {
  	io.Copy(c, c) // NOTE: ignoring errors
  	c.Close()
  }
  ```

- 一个更有意思的echo服务应该模拟一个实际的echo的“回响”，并且一开始要用大写HELLO来表示“声音很大”，之后经过一小段延迟返回一个有所缓和的Hello，然后一个全小写字母的hello表示声音渐渐变小直至消失，像下面这个版本的handleConn

  <u><i>gopl.io/ch8/reverb1</i></u>
  
  ```go
  func echo(c net.Conn, shout string, delay time.Duration) {
  	fmt.Fprintln(c, "\t", strings.ToUpper(shout))
  	time.Sleep(delay)
  	fmt.Fprintln(c, "\t", shout)
  	time.Sleep(delay)
  	fmt.Fprintln(c, "\t", strings.ToLower(shout))
  }
  
  func handleConn(c net.Conn) {
  	input := bufio.NewScanner(c)
  	for input.Scan() {
  		echo(c, input.Text(), 1*time.Second)
  	}
  	// NOTE: ignoring potential errors from input.Err()
  	c.Close()
  }
  ```

- 我们需要升级我们的客户端程序，这样它就可以发送终端的输入到服务器，并把服务端的返回输出到终端上，这使我们有了使用并发的另一个好机会：

  <u><i>gopl.io/ch8/netcat2</i></u>
  
  ```go
  func main() {
  	conn, err := net.Dial("tcp", "localhost:8000")
  	if err != nil {
  		log.Fatal(err)
  	}
  	defer conn.Close()
  	go mustCopy(os.Stdout, conn)
  	mustCopy(conn, os.Stdin)
  }
  ```

- 当main goroutine从标准输入流中读取内容并将其发送给服务器时，另一个goroutine会读取并打印服务端的响应。当main goroutine碰到输入终止时，例如，用户在终端中按了Control-D(^D)，在windows上是Control-Z，这时程序就会被终止，尽管其它goroutine中还有进行中的任务。（在8.4.1中引入了channels后我们会明白如何让程序等待两边都结束。）
- 下面这个会话中，客户端的输入是左对齐的，服务端的响应会用缩进来区别显示。
- 客户端会向服务器“喊三次话”：

  ```
  $ go build gopl.io/ch8/reverb1
  $ ./reverb1 &
  $ go build gopl.io/ch8/netcat2
  $ ./netcat2
  Hello?
      HELLO?
      Hello?
      hello?
  Is there anybody there?
      IS THERE ANYBODY THERE?
  Yooo-hooo!
      Is there anybody there?
      is there anybody there?
      YOOO-HOOO!
      Yooo-hooo!
      yooo-hooo!
  ^D
  $ killall reverb1
  ```

- 注意客户端的第三次shout在前一个shout处理完成之前一直没有被处理，这貌似看起来不是特别“现实”。真实世界里的回响应该是会由三次shout的回声组合而成的。为了模拟真实世界的回响，我们需要更多的goroutine来做这件事情。这样我们就再一次地需要go这个关键词了，这次我们用它来调用echo：

  <u><i>gopl.io/ch8/reverb2</i></u>
  
  ```go
  func handleConn(c net.Conn) {
  	input := bufio.NewScanner(c)
  	for input.Scan() {
  		go echo(c, input.Text(), 1*time.Second)
  	}
  	// NOTE: ignoring potential errors from input.Err()
  	c.Close()
  }
  ```

	- go后跟的函数的参数会在go语句自身执行时被求值；因此input.Text()会在main goroutine中被求值。
	- 现在回响是并发并且会按时间来覆盖掉其它响应了：

	  ```
	  $ go build gopl.io/ch8/reverb2
	  $ ./reverb2 &
	  $ ./netcat2
	  Is there anybody there?
	      IS THERE ANYBODY THERE?
	  Yooo-hooo!
	      Is there anybody there?
	      YOOO-HOOO!
	      is there anybody there?
	      Yooo-hooo!
	      yooo-hooo!
	  ^D
	  $ killall reverb2
	  ```

- 让服务使用并发不只是处理多个客户端的请求，甚至在处理单个连接时也可能会用到，就像我们上面的两个go关键词的用法。然而在我们使用go关键词的同时，需要慎重地考虑net.Conn中的方法在并发地调用时是否安全，事实上对于大多数类型来说也确实不安全。我们会在下一章中详细地探讨并发安全性。

