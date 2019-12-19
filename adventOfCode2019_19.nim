
import strutils
import sequtils
import sets
import algorithm

const
  gcInput = @[109i64, 424, 203, 1, 21101, 0, 11, 0, 1106, 0, 282, 21102, 18, 1,
      0, 1105, 1, 259, 1202, 1, 1, 221, 203, 1, 21102, 31, 1, 0, 1106, 0, 282,
      21101, 0, 38, 0, 1106, 0, 259, 20101, 0, 23, 2, 21201, 1, 0, 3, 21101, 0,
      1, 1, 21101, 57, 0, 0, 1105, 1, 303, 1202, 1, 1, 222, 21001, 221, 0, 3,
      21001, 221, 0, 2, 21101, 0, 259, 1, 21101, 80, 0, 0, 1105, 1, 225, 21101,
      119, 0, 2, 21102, 1, 91, 0, 1106, 0, 303, 2101, 0, 1, 223, 20102, 1, 222,
      4, 21102, 1, 259, 3, 21101, 0, 225, 2, 21101, 0, 225, 1, 21101, 0, 118, 0,
      1105, 1, 225, 21002, 222, 1, 3, 21101, 97, 0, 2, 21101, 133, 0, 0, 1106,
      0, 303, 21202, 1, -1, 1, 22001, 223, 1, 1, 21102, 148, 1, 0, 1105, 1, 259,
      1201, 1, 0, 223, 20101, 0, 221, 4, 20102, 1, 222, 3, 21101, 21, 0, 2,
      1001, 132, -2, 224, 1002, 224, 2, 224, 1001, 224, 3, 224, 1002, 132, -1,
      132, 1, 224, 132, 224, 21001, 224, 1, 1, 21102, 1, 195, 0, 106, 0, 109,
      20207, 1, 223, 2, 20101, 0, 23, 1, 21101, -1, 0, 3, 21101, 0, 214, 0,
      1105, 1, 303, 22101, 1, 1, 1, 204, 1, 99, 0, 0, 0, 0, 109, 5, 2102, 1, -4,
      249, 21202, -3, 1, 1, 22101, 0, -2, 2, 21201, -1, 0, 3, 21102, 1, 250, 0,
      1106, 0, 225, 21201, 1, 0, -4, 109, -5, 2105, 1, 0, 109, 3, 22107, 0, -2,
      -1, 21202, -1, 2, -1, 21201, -1, -1, -1, 22202, -1, -2, -2, 109, -3, 2106,
      0, 0, 109, 3, 21207, -2, 0, -1, 1206, -1, 294, 104, 0, 99, 22101, 0, -2,
      -2, 109, -3, 2106, 0, 0, 109, 5, 22207, -3, -4, -1, 1206, -1, 346, 22201,
      -4, -3, -4, 21202, -3, -1, -1, 22201, -4, -1, 2, 21202, 2, -1, -1, 22201,
      -4, -1, 1, 21202, -2, 1, 3, 21101, 0, 343, 0, 1106, 0, 303, 1106, 0, 415,
      22207, -2, -3, -1, 1206, -1, 387, 22201, -3, -2, -3, 21202, -2, -1, -1,
      22201, -3, -1, 3, 21202, 3, -1, -1, 22201, -3, -1, 2, 22101, 0, -4, 1,
      21102, 384, 1, 0, 1106, 0, 303, 1106, 0, 415, 21202, -4, -1, -4, 22201,
      -4, -3, -4, 22202, -3, -2, -2, 22202, -2, -4, -4, 22202, -3, -2, -3,
      21202, -4, -1, -2, 22201, -3, -2, 1, 22102, 1, 1, -4, 109, -5, 2106, 0, 0]


type
  MachineStatus = enum
    ready
    waitInput
    finish
    error

  Machine = tuple
    status: MachineStatus
    input: seq[BiggestInt]
    memory: seq[BiggestInt]
    ip: BiggestInt
    base: BiggestInt
    output: seq[BiggestInt]

proc runProgram(aMachine: var Machine) =
  if ready == aMachine.status:
    while true:
      let lInstructionStr = ($aMachine.memory[aMachine.ip]).align(5, '0')

      template getMemory(aPosition: BiggestInt): BiggestInt =
        block getMemory:
          if (aMachine.memory.len <= aPosition):
            aMachine.memory.setLen(aPosition+1000)
          aMachine.memory[aPosition]

      template setMemory(aPosition: BiggestInt, aValue: BiggestInt) =
        block setMemory:
          if (aMachine.memory.len <= aPosition):
            aMachine.memory.setLen(aPosition+1000)
          aMachine.memory[aPosition] = aValue

      template getParam(aParam: int, aAddress: bool = false): BiggestInt =
        block getParam:
          var lResult = getMemory(aMachine.ip + aParam)
          case lInstructionStr[3-aParam]:
            of '0':
              if not aAddress:
                lResult = getMemory(lResult)
            of '2':
              lResult += aMachine.base
              if not aAddress:
                lResult = getMemory(lResult)
            else:
              discard
          lResult


      let lOpCode = lInstructionStr[3..4].parseBiggestInt
      case lOpCode
      of 1:
        let lX1 = getParam(1)
        let lX2 = getParam(2)
        let lA3 = getParam(3, true)
        setMemory(lA3, (lX1 + lX2))
        aMachine.ip += 4

      of 2:
        let lX1 = getParam(1)
        let lX2 = getParam(2)
        let lA3 = getParam(3, true)
        setMemory(lA3, (lX1 * lX2))
        aMachine.ip += 4

      of 3:
        if aMachine.input.len > 0:
          let lA1 = getParam(1, true)
          setMemory(lA1, aMachine.input.pop)
          aMachine.ip += 2
        else:
          aMachine.status = waitInput
          break

      of 4:
        let lX1 = getParam(1)
        aMachine.output.insert(lX1, 0)
        aMachine.ip += 2

      of 5:
        let lX1 = getParam(1)
        let lX2 = getParam(2)
        if (0 != lX1):
          aMachine.ip = lX2
        else:
          aMachine.ip += 3

      of 6:
        let lX1 = getParam(1)
        let lX2 = getParam(2)
        if (0 == lX1):
          aMachine.ip = lX2
        else:
          aMachine.ip += 3

      of 7:
        let lX1 = getParam(1)
        let lX2 = getParam(2)
        let lA3 = getParam(3, true)
        if (lX1 < lX2):
          setMemory(lA3, 1)
        else:
          setMemory(lA3, 0)
        aMachine.ip += 4

      of 8:
        let lX1 = getParam(1)
        let lX2 = getParam(2)
        let lA3 = getParam(3, true)
        if (lX1 == lX2):
          setMemory(lA3, 1)
        else:
          setMemory(lA3, 0)
        aMachine.ip += 4

      of 9:
        let lX1 = getParam(1)
        aMachine.base += lX1
        aMachine.ip += 2

      of 99:
        aMachine.status = finish
        break

      else:
        aMachine.status = error
        break

proc partOne =
  const
    lcMachine: Machine = (
      ready,
      @[],
      gcInput,
      0i64,
      0i64,
      @[]
    )
  var
    lCount = 0i64

  for y in 0i64..49:
    for x in 0i64..49:
      var lMachine = lcMachine
      lMachine.input.insert(@[x, y].reversed, 0)
      runProgram(lMachine)
      if lMachine.output.len > 0:
        let lPixel = lMachine.output.pop
        lCount += lPixel

  echo "partOne ", lCount

proc partTwo =
  const
    lcMachine: Machine = (
      ready,
      @[],
      gcInput,
      0i64,
      0i64,
      @[]
    )

  var x = 0i64
  var y = 0i64
  for y in 0i64..49:
    for x in 0i64..49:
      var lMachine = lcMachine
      lMachine.input.insert(@[x, y].reversed, 0)
      runProgram(lMachine)
      if lMachine.output.len > 0:
        let lPixel = lMachine.output.pop

  echo "partTwo ", 2


partOne() # XXXX
partTwo() # XXXX
