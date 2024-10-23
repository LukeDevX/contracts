// 导入 `deploy` 和 `ownable` 模块，分别用于合约部署和所有者控制功能
import "@stdlib/deploy";
import "@stdlib/ownable";

// https://tact-by-example.org/06-unbounded-arrays
// arrays

// 这段代码定义了一个 父合约和多个子合约，用于管理待办任务列表。父合约负责：

// 添加新任务（任何人都可以）。
// 标记任务为完成（仅限所有者）。
// 每个任务被映射为一个子合约，记录其状态（描述和是否完成）。


// 定义一个消息结构，用于接收新待办任务的请求
message NewTodo {
    task: String; // 任务的描述
}

// 定义新待办任务创建成功后的响应消息，返回任务的序列号（seqno）
message NewTodoResponse {
    seqno: Int as uint256; // 使用 uint256 类型表示任务序列号
}

// 定义用于标记任务完成的消息，包含任务序列号
message CompleteTodo {
    seqno: Int as uint256; // 完成的任务序号
}

// 定义主合约，用户只能与这个父合约交互
// users are supposed to interact with this parent contract only 
contract TodoParent with Deployable, Ownable {
 
    owner: Address;
    numTodos: Int as uint256 = 0; // 记录当前任务总数，初始为 0

    // 初始化函数：在合约部署时执行，将合约部署者设置为所有者
    init() { // 可传入地址参数
        self.owner = sender(); // set the owner as the deployer // 记录部署者地址为所有者地址
    }

    // 接收新待办任务的消息，允许任何人添加任务
    // anybody can add a new todo, not just the owner 
    receive(msg: NewTodo) {
        self.numTodos = self.numTodos + 1; // 每收到一个任务，自增任务总数
        let init: StateInit = initOf TodoChild(myAddress(), self.numTodos); // 为新任务创建一个子合约的初始化数据


        // 回调处理
        //master调用wallet，如果不能返回，就用bounce进行处理，进入mint的处理
        // A：mint控制中心（mint方法，mint判断方法）
        // B：分配mint和存储身份（mint）
        // C：用户身份
       


        // 错误处理 try catch
        // 计算合约地址（当前合约和地址）：添加搜索其他地址是否添加过？？？
        // 判断成功（地址计数）mint计数，判断+1
        // 判断失败，则执行mint逻辑


        // 部署子合约并传入任务数据
        send(SendParameters{
            to: contractAddress(init), // 发送给新子合约地址
            body: InternalSetTask{task: msg.task}.toCell(), // 将任务数据作为消息体传递
            value: ton("0.02"),             // pay for the deployment and leave some TON in the child for storage // 支付部署费用并留一些 TON 作为子合约存储费用
            mode: SendIgnoreErrors, // 忽略发送错误模式
            code: init.code,                // prepare the initial code when deploying the child contract
            data: init.data
        });
        // 回复调用者，返回新任务的序列号
        self.reply(NewTodoResponse{seqno: self.numTodos}.toCell()); // this will return excess gas to sender // 返回新任务的序列号
    }

    // 只允许合约所有者调用此函数以标记任务为完成状态
    // only the owner can mark a todo as completed  
    receive(msg: CompleteTodo) {
        self.requireOwner();  // 确保调用者是所有者
        require(msg.seqno <= self.numTodos, "Todo does not exist"); // 验证任务是否存在

        // 发送消息给对应的子合约，标记任务完成
        send(SendParameters{ // this will forward excess gas
            to: contractAddress(initOf TodoChild(myAddress(), msg.seqno)), // 目标子合约地址
            body: InternalComplete{excess: sender()}.toCell(), // 传递完成任务的请求
            value: 0, /// TODO: https://github.com/tact-lang/tact/issues/31 // 当前不转移资金（TODO：后续实现）
            mode: SendRemainingValue + SendIgnoreErrors /// TODO: issues/31  // 使用剩余资金模式，忽略错误
        });
    }

    // 公共方法，返回当前任务总数
    get fun numTodos(): Int {
        return self.numTodos;
    }

    // 公共方法，根据序列号返回对应任务的子合约地址
    get fun todoAddress(seqno: Int): Address {
        return contractAddress(initOf TodoChild(myAddress(), seqno));
    }
}

////////////////////////////////////////////////////////////////////////////
// child contract - internal interface that users shouldn't access directly
// 子合约部分：实现单个待办任务的逻辑（用户不应直接与子合约交互）

// 定义一个消息，用于设置任务数据
message InternalSetTask {
    task: String;  // 任务描述
}

// 定义一个消息，用于标记任务完成，并传递多余的资金
message InternalComplete {
    excess: Address;  // 用于退还多余资金的地址
}

// 定义任务详情的结构，包括任务描述和完成状态
struct TodoDetails {
    seqno: Int as uint256;
    task: String;  // 任务描述
    completed: Bool;  // 是否完成
}

// 定义子合约：每个待办任务都对应一个独立的子合约
contract TodoChild {
    parent: Address;  // 父合约地址
    seqno: Int as uint256;  // 任务序列号
    task: String = "";  // 初始化为空字符串的任务描述
    completed: Bool = false;  // 初始化为未完成状态

    // 初始化函数：设置父合约地址和任务序号
    init(parent: Address, seqno: Int) {
        self.parent = parent;  // 记录父合约地址
        self.seqno = seqno;  // 记录任务序列号
    }

    // 接收来自父合约的任务设置消息
    receive(msg: InternalSetTask) {
        require(sender() == self.parent, "Parent only");  // 确保调用者是父合约
        self.task = msg.task;  // 设置任务描述
        send(SendParameters{ // this will return excess gas to original sender
            to: msg.excess, // 退还多余资金的目标地址
            value: 0, /// TODO: https://github.com/tact-lang/tact/issues/31  // 当前不转移资金（TODO：后续实现）
            mode: SendRemainingBalance + SendIgnoreErrors /// TODO: issues/31 // 使用剩余余额模式，忽略错误
        });
    }

    // 接收来自父合约的完成任务消息
    receive(msg: InternalComplete) {
        require(sender() == self.parent, "Parent only");  // 确保调用者是父合约
        self.completed = true;  // 标记任务为完成

        // 将多余的资金退还给指定地址
        send(SendParameters{ // this will return excess gas to original sender
            to: msg.excess, // 退还多余资金的目标地址
            value: 0, /// TODO: https://github.com/tact-lang/tact/issues/31  // 当前不转移资金（TODO：后续实现）
            mode: SendRemainingBalance + SendIgnoreErrors /// TODO: issues/31 // 使用剩余余额模式，忽略错误
        });
    }

    // 结构体，scan中解析不了，可能通过rpc可以解析
    // 公共方法，返回任务的详情（描述和完成状态）
    get fun details(): TodoDetails {
        return TodoDetails{
            seqno: self.seqno,
            task: self.task,  // 任务描述
            completed: self.completed  // 完成状态
        };
    }
//     "01"
// boc：x{746573743031} 
// base64：<=>te6cckEBAQEACAAADHRlc3QwMTaYNF0=
// "00"
   
   // 获取编号
   // 1
    get fun getSeqno(): Int {
        return self.seqno;
    }

// base64：te6cckEBAQEACAAADHRlc3QwMTaYNF0=
// boc：x{746573743031}
    // 内容
    get fun getTask(): String {
        return self.task;
    }

   
}